<?php


namespace VrsMedia\Composer;

use Composer\IO\IOInterface;
use Composer\Script\Event;
use Doctrine\Common\Cache\VoidCache;
use Doctrine\DBAL\DriverManager;
use VrsMedia\Database\ProgressPrinter;
use VrsMedia\Database\TransferService;
use VrsMedia\Docker\Configuration;
use VrsMedia\Docker\VolumeMount;
use VrsMedia\Docker\YamlConfigurationGenerator;
use VrsMedia\Phing\UsagePrinter;

class ComposerHook
{
    /**
     * @var Event
     */
    private $event;

    /**
     * @var string
     */
    private $rootDirectory;

    /**
     * @var ParameterDefinition
     */
    private $parameters;

    /**
     * ComposerHook constructor.
     *
     * @param Event $event
     */
    public function __construct(Event $event)
    {
        $this->event         = $event;
        $this->rootDirectory = $this->getRootDirectory();
        $this->parameters    = $this->getParameterDefinition();
    }

    /**
     * Return the absolute path of the projects root directory
     *
     * @return string
     */
    private function getRootDirectory()
    {
        $cwd    = getcwd();
        $config = '/composer.json';

        if (!file_exists($cwd . $config))
        {
            throw new \RuntimeException('FATAL: Could not find root directory');
        }

        return $cwd;
    }

    /**
     * @return ParameterDefinition
     */
    private function getParameterDefinition()
    {
        $parser = new ParameterParser();
        $extra  = $this->getExtraOptions();

        return $parser->parse($extra);
    }

    /**
     * @return array
     */
    private function getExtraOptions()
    {
        $package = $this->event->getComposer()->getPackage();
        $extra   = $package->getExtra();

        return $extra;
    }

    private function printHeader()
    {
        $this->getIO()->write('VRS Media GmbH & Co. KG');
        $this->getIO()->write('=======================');
        $this->getIO()->write('AMAKER Installation');
        $this->getIO()->write('This tool aims at providing an easy to use interface to the docker application');
    }

    /**
     * @param Event $event
     */
    public static function postInstall(Event $event)
    {
        $hook = new self($event);
        $hook->printHeader();
        $hook->generateDockerConfiguration($hook->resolvePackages());
        $hook->makeAmakerExecutable();
    }

    /**
     * @param Event $event
     */
    public static function startContainer(Event $event)
    {
        $hook = new self($event);
        if ($event->getIO()->askConfirmation('Do you want to start the containers now?  (yes)', true))
        {
            $hook->amaker('start');
        }
    }

    /**
     * Exectue the amaker.
     *
     * @param string $command
     */
    private function amaker($command)
    {
        passthru(sprintf('%s/amaker %s', getcwd(), $command));
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
     * Does a chmod on the amaker tool
     */
    private function makeAmakerExecutable()
    {
        $amaker = $this->rootDirectory . '/amaker';
        chmod($amaker, 0777);
    }

    /**
     * Resolves the required packages
     *
     * @return VolumeMount[]
     */
    private function resolvePackages()
    {
        $resolver = new PackageResolver($this->getIO());

        $packages = $this->parameters->getPackages();
        return $resolver->resolvePackages($packages, $this->rootDirectory);
    }

    /**
     * @return IOInterface
     */
    private function getIO()
    {
        return $this->event->getIO();
    }

    /**
     * Generate the docker-compose.yaml
     * @param VolumeMount[] $mounts
     */
    private function generateDockerConfiguration(array $mounts)
    {
        $outputFile = $this->rootDirectory . '/docker-compose.yml';

        $configuration = $this->getDockerConfiguration();
        foreach ($mounts as $mount)
        {
            $configuration->addVolumeMount($mount);
        }

        $generator = new YamlConfigurationGenerator($configuration);
        $output    = $generator->generate();

        file_put_contents($outputFile, $output);
    }

    /**
     * @return Configuration
     */
    private function getDockerConfiguration()
    {
        $configuration = new Configuration();

        $io = $this->getIO();
        $dbPort = 3306;
        $httpdPort = 80;
        if ($io->askConfirmation('Do you want to change the default exposed application ports? (no)', false))
        {
            $io->write('Please specify the ports on which the application should be binded to');
            $dbPort    = $io->ask('Database ('. $dbPort .'): ', $dbPort);
            $httpdPort = $io->ask('Webserver ('. $httpdPort .'): ', $httpdPort);

        }

        $configuration->setDatabasePort($dbPort);
        $configuration->setHttpdPort($httpdPort);

        return $configuration;
    }
}