<?php


namespace VrsMedia\Composer;


class ParameterDefinition
{
    /**
     * @var string
     */
    private $buildFile;

    /**
     * @var PackageDefinition[]
     */
    private $packages;

    /**
     * ParameterDefinition constructor.
     *
     * @param string              $buildFile
     * @param PackageDefinition[] $packages
     */
    public function __construct($buildFile, array $packages)
    {
        $this->buildFile = $buildFile;
        $this->packages  = $packages;
    }

    /**
     * @return string
     */
    public function getBuildFile()
    {
        return $this->buildFile;
    }

    /**
     * @return PackageDefinition[]
     */
    public function getPackages()
    {
        return $this->packages;
    }

}