<?php


namespace VrsMedia\Docker;


use Exception;

class YamlConfigurationGenerator
{
    /**
     * @var Configuration
     */
    private $configuration;

    /**
     * YamlConfigurationGenerator constructor.
     *
     * @param Configuration $configuration
     *
     * @throws Exception
     */
    public function __construct(Configuration $configuration)
    {
        $this->configuration = $configuration;
    }

    /**
     * @return string
     * @throws Exception
     */
    public function generate()
    {
        $this->validateConfiguration($this->configuration);

        $configs = [
            $this->generateAppConfiguration(),
            $this->generateDatabaseConfiguration(),
            $this->generateHttpdConfiguration()
        ];

        return implode("\n", $configs);
    }

    /**
     * @param Configuration $configuration
     *
     * @throws Exception
     */
    private function validateConfiguration(Configuration $configuration)
    {
        if (empty($configuration->getVolumeMounts()))
        {
            throw $this->emptyMountsException();
        }
    }

    /**
     * @return Exception
     */
    private function emptyMountsException()
    {
        return new Exception('There are no external project packages configured as mounted volume');
    }

    /**
     * @param VolumeMount[] $mounts
     *
     * @return string
     */
    private function generateVolumeList($mounts)
    {
        $volumes = [];

        foreach ($mounts as $mount)
        {
            $volumes[] = $this->generateVolumeInstruction($mount);
        }

        return implode("\n", $volumes);
    }

    /**
     * @param $mount
     *
     * @return string
     */
    private function generateVolumeInstruction(VolumeMount $mount)
    {
        $source = $mount->getSourceDirectory();
        $target = $mount->getTargetDirectory();
        $volume = sprintf("    - %s:%s", $source, $target);

        return $volume;
    }

    /**
     * @return string
     */
    private function generateAppConfiguration()
    {
        $volumes = $this->generateVolumeList($this->configuration->getVolumeMounts());

        return <<<CONFIG
# This container serves as a pure data container
app:
  build: app/
  container_name: amak-app
  volumes:
$volumes

CONFIG;
    }

    /**
     * @return string
     */
    private function generateDatabaseConfiguration()
    {
        $port   = $this->configuration->getDatabasePort();
        $dbPort = $this->generatePortInstruction($port, 3306);

        return <<<CONFIG
# Percona database
db:
  build: db/
  container_name: amak-db
  ports:
$dbPort
  environment:
    - MYSQL_ROOT_PASSWORD=root
    - MYSQL_DATABASE=amak

CONFIG;
    }

    private function generateHttpdConfiguration()
    {
        $port      = $this->configuration->getHttpdPort();
        $httpdPort = $this->generatePortInstruction($port, 80);

        return <<<CONFIG
# Apache2 httpd
httpd:
  build: httpd/
  container_name: amak-httpd
  ports:
$httpdPort
  links:
    - db
  volumes_from:
    - app:rw

CONFIG;
    }

    /**
     * @param int $sourcePort
     * @param int $targetPort
     *
     * @return string
     */
    private function generatePortInstruction($sourcePort, $targetPort)
    {
        return sprintf("    - \"%d:%d\"", $sourcePort, $targetPort);
    }
}