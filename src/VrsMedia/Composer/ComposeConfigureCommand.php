<?php

namespace VrsMedia\Composer;


use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use VrsMedia\Docker\Configuration;
use VrsMedia\Docker\VolumeMount;
use VrsMedia\Docker\YamlConfigurationGenerator;

class ComposeConfigureCommand extends Command
{


    /**
     * ComposeConfigureCommand constructor.
     */
    public function __construct()
    {
        parent::__construct('compose-config');
    }

    public function run(InputInterface $input, OutputInterface $output)
    {
        $this->generateDockerConfiguration($this->resolvePackages());
    }

    public function getDescription()
    {
        return 'Configure docker compose.';
    }


    /**
     * Generate the docker-compose.yaml
     * @param VolumeMount[] $mounts
     */
    private function generateDockerConfiguration(array $mounts)
    {
        $outputFile = AMAKER_HOME . '/docker-compose.yml';

        $configuration = $this->getDockerConfiguration();
        foreach ($mounts as $mount)
        {
            $configuration->addVolumeMount($mount);
        }

        $generator = new YamlConfigurationGenerator($configuration);
        $output    = $generator->generate();

        file_put_contents($outputFile, $output);
        file_put_contents(AMAKER_HOME . '/private.properties', "docker.prefix=" . $configuration->getPrefix());
    }


    /**
     * @return \VrsMedia\Docker\VolumeMount[]
     * @throws \Exception
     */
    private function resolvePackages()
    {
        $resolver = new PackageResolver($this->getApplication()->getIO());
        return $resolver->resolvePackages($this->getApplication()->getParameterProvider()->getParameters()->getPackages(), AMAKER_HOME);
    }

    /**
     * @return Configuration
     */
    private function getDockerConfiguration()
    {
        $configuration = new Configuration();

        $dbPort = 3306;
        $httpdPort = 80;
        if ($this->getApplication()->getIO()->askConfirmation('Do you want to change the default exposed application ports? (no)', false))
        {
            $this->getApplication()->getIO()->write('Please specify the ports on which the application should be binded to');
            $dbPort    = $this->getApplication()->getIO()->ask('Database ('. $dbPort .'): ', $dbPort);
            $httpdPort = $this->getApplication()->getIO()->ask('Webserver ('. $httpdPort .'): ', $httpdPort);

        }

        $configuration->setPrefix($this->getApplication()->getIO()->ask('Please supply the default container prefix? (amak)', 'amak'));

        $configuration->setDatabasePort($dbPort);
        $configuration->setHttpdPort($httpdPort);

        return $configuration;
    }
}