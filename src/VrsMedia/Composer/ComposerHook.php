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
     * Import the database
     */
    public static function importDatabase(Event $event)
    {
        $io = $event->getIO();

        $io->write('Please specify the source AMAK database.');

        $dockerhost = '127.0.0.1';
        if (getenv('DOCKER_HOST'))
        {
            preg_match('|(\d+\.\d+\.\d+\.\d+)|', getenv('DOCKER_HOST'), $matches);
            $dockerhost = $matches[0];
        }
        $sourceParams = [
            'host'     => $io->ask('Host ('. $dockerhost .'): ', $dockerhost),
            'dbname'   => $io->ask('Database (amak): ', 'amak'),
            'user'     => $io->ask('User (root):', 'root'),
            'password' => $io->ask('Password (root): ', 'root'),
            'driver'   => 'pdo_mysql',
        ];

        $io->write('');
        exec('docker-machine ip default', $output, $code);

        $localIp = null;

        if($code == 0 && is_array($output)) {
            $localIp = $output[0];
        } else {
            $localIp = $io->askConfirmation('IP of target database: ');
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
        $io->write('Please specify the ports on which the application should be binded to');

        $dbPort    = $io->ask('Database (3306): ', '3306');
        $httpdPort = $io->ask('Webserver (80): ', '80');

        $configuration->setDatabasePort($dbPort);
        $configuration->setHttpdPort($httpdPort);

        return $configuration;
    }
}