<?php


namespace VrsMedia\Composer;

use Composer\IO\IOInterface;
use Composer\Script\Event;
use Doctrine\Common\Cache\VoidCache;
use Doctrine\DBAL\DriverManager;
use VrsMedia\Database\ProgressPrinter;
use VrsMedia\Database\TransferService;

class ComposerHook
{
    /**
     * @var Event
     */
    private $event;


    /**
     * ComposerHook constructor.
     *
     * @param Event $event
     */
    public function __construct(Event $event)
    {
        $this->event = $event;
    }


    /**
     * @param Event $event
     */
    public static function postInstall(Event $event)
    {
        // $hook = new self($event);
        $event->getIO()->write('Please run ./amaker now!');
    }


    /**
     * Import the database
     */
    public static function importDatabase(Event $event)
    {
        $io = $event->getIO();


        if (!$io->askConfirmation('Do you want to import a existing database now? (no)', false))
        {
            return;
        }

        $io->write('Please specify the source AMAK database.');


        $sourceParams = [
            'host'     => $io->ask('Source-Host:'),
            'dbname'   => $io->ask('Source-Database (amak): ', 'amak'),
            'user'     => $io->ask('Source-User:'),
            'password' => $io->ask('Source-Password:'),
            'driver'   => 'pdo_mysql',
        ];

        $io->write('');
        exec('docker-machine ip default', $output, $code);

        $localIp = '127.0.0.1';
        if (getenv('DOCKER_HOST'))
        {
            preg_match('|(\d+\.\d+\.\d+\.\d+)|', getenv('DOCKER_HOST'), $matches);
            $localIp = $matches[0];
        }

        $targetParams = [
            'dbname'   => 'amak',
            'user'     => 'root',
            'password' => 'root',
            'host'     => $localIp,
            'driver'   => 'pdo_mysql',
        ];

        $sourceConnection = DriverManager::getConnection($sourceParams);
        $targetConnection = DriverManager::getConnection($targetParams);

        $progressPrinter = new ProgressPrinter($io);

        $service = new TransferService($sourceConnection, $targetConnection, $progressPrinter);
        $service->transferDatabase();
    }


    /**
     * @return IOInterface
     */
    private function getIO()
    {
        return $this->event->getIO();
    }
}