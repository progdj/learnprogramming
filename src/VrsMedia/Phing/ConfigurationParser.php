<?php

namespace VrsMedia\Phing;

use RuntimeException;

class ConfigurationParser
{
    /**
     * @var string
     */
    private $configurationFile;

    /**
     * ConfigurationParser constructor.
     *
     * @param string $configurationFile
     */
    public function __construct($configurationFile)
    {
        $this->setConfigurationFile($configurationFile);
    }

    /**
     * @param string $configurationFile
     */
    public function setConfigurationFile($configurationFile)
    {
        $this->validateFileExists($configurationFile);
        $this->configurationFile = $configurationFile;
    }

    /**
     * @return Target[]
     */
    public function getTargets()
    {
        $simpleXml = simplexml_load_file($this->configurationFile);
        $targets = [];

        foreach ($simpleXml->target as $target)
        {
            $name        = $target['name'];
            $description = $target['description'];

            $targets[] = new Target((string)$name, (string)$description);
        }

        return $targets;
    }

    /**
     * @param $configurationFile
     *
     * @throws RuntimeException
     */
    private function validateFileExists($configurationFile)
    {
        if (!file_exists($configurationFile))
        {
            throw new RuntimeException('Could not find build configuration: ' . $configurationFile);
        }
    }

}