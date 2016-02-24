<?php


namespace VrsMedia\Docker;


class VolumeMount
{
    /**
     * @var string
     */
    private $sourceDir;

    /**
     * @var string
     */
    private $targetDir;

    /**
     * Volume constructor.
     *
     * @param string $sourceDir
     * @param string $targetDir
     */
    public function __construct($sourceDir, $targetDir)
    {
        $this->sourceDir = $sourceDir;
        $this->targetDir = $targetDir;
    }

    /**
     * @return string
     */
    public function getSourceDirectory()
    {
        return $this->sourceDir;
    }

    /**
     * @return string
     */
    public function getTargetDirectory()
    {
        return $this->targetDir;
    }

}