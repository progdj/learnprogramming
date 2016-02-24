<?php


namespace VrsMedia\Database;


use Doctrine\DBAL\Connection;
use Doctrine\DBAL\DriverManager;
use Doctrine\DBAL\Query\QueryBuilder;
use Doctrine\DBAL\Schema\Schema;
use Doctrine\DBAL\Schema\Table;

class TransferService
{

    /**
     * @var Connection
     */
    private $source, $target;

    /**
     * @var ProgressPrinter
     */
    private $progressPrinter;

    /**
     * TransferService constructor.
     *
     * @param Connection      $source
     * @param Connection      $target
     * @param ProgressPrinter $progressPrinter
     */
    public function __construct(Connection $source, Connection $target, ProgressPrinter $progressPrinter)
    {
        $this->source          = $source;
        $this->target          = $target;
        $this->progressPrinter = $progressPrinter;
    }

    /**
     * Transfers the whole source database to the target database
     */
    public function transferDatabase()
    {
        $this->registerEnumAsString();
        $this->setForeignKeyChecks(0);

        $this->progressPrinter->write("Importing schema...");
        $this->transferSchema();
        $this->progressPrinter->write("Importing data...");
        $this->transferData();
        $this->progressPrinter->write("Done.");

        $this->setForeignKeyChecks(1);
    }

    /**
     * @param bool $enable
     *
     * @throws \Doctrine\DBAL\DBALException
     */
    private function setForeignKeyChecks($enable)
    {
        $this->target->executeQuery('SET FOREIGN_KEY_CHECKS=' . ((int)$enable));
    }

    private function registerEnumAsString()
    {
        $this->source->getDatabasePlatform()->registerDoctrineTypeMapping('enum', 'string');
        $this->target->getDatabasePlatform()->registerDoctrineTypeMapping('enum', 'string');
    }

    /**
     * @return Table[]
     */
    private function getSourceTables()
    {
        static $tables = null;

        if (isset($tables))
        {
            $cached = $tables;
            unset($tables);

            return $cached;
        }

        $schemaManager = $this->source->getSchemaManager();
        $tables        = $schemaManager->listTables();

        return $tables;
    }

    /**
     * @param Table $table
     */
    private function createTargetTable(Table $table)
    {
        $this->target->getSchemaManager()->createTable($table);
    }

    /**
     * @return QueryBuilder
     */
    private function createSourceQuery()
    {
        return $this->source->createQueryBuilder();
    }

    private function transferSchema()
    {
        $tables = $this->getSourceTables();

        foreach ($tables as $table)
        {
            $this->createTargetTable($table);
        }
    }

    private function transferData()
    {
        $tables = $this->getSourceTables();

        $this->progressPrinter->write('Preparing...');
        $this->progressPrinter->write('', false);

        $totalCount = $this->getTotalCount();
        $this->progressPrinter->setTotal($totalCount);

        foreach ($tables as $table)
        {
            $name = $table->getName();
            $this->progressPrinter->setTable($name);

            $query   = $this->createSourceQuery()->select('*')->from($name);
            $results = $query->execute();

            while ($result = $results->fetch())
            {
                $data = $this->quoteData($result);
                $this->target->insert($name, $data);
                $this->progressPrinter->increment();
            }
        }
    }

    /**
     * @return int
     */
    private function getTotalCount()
    {
        $tables = $this->getSourceTables();
        $total  = 0;

        foreach ($tables as $table)
        {
            $name = $table->getName();

            $query   = $this->createSourceQuery()->select('*')->from($name);
            $results = $query->execute();

            $total += $results->rowCount();
        }

        return $total;
    }

    /**
     * @param $result
     *
     * @return array
     */
    private function quoteData($result)
    {
        $data = [];
        foreach ($result as $column => $value)
        {
            $data[$this->target->quoteIdentifier($column)] = $value;
        }

        return $data;
    }

}