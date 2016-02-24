<?php


namespace VrsMedia\Docker;


class Configuration
{
    /**
     * @var VolumeMount[]
     */
    private $mounts = array();

    /**
     * @var int
     */
    private $httpdPort = 80;

    /**
     * @var int
     */
    private $databasePort = 3306;

    /**
     * @var string
     */
    private $prefix = 'amak';

    /**
     * @return VolumeMount[]
     */
    public function getVolumeMounts()
    {
        return $this->mounts;
    }

    /**
     * @param VolumeMount $mount
     */
    public function addVolumeMount(VolumeMount $mount)
    {
        $this->mounts[] = $mount;
    }

    /**
     * @return int
     */
    public function getHttpdPort()
    {
        return $this->httpdPort;
    }

    /**
     * @param int $httpdPort
     */
    public function setHttpdPort($httpdPort)
    {
        $this->httpdPort = $httpdPort;
    }

    /**
     * @return int
     */
    public function getDatabasePort()
    {
        return $this->databasePort;
    }

    /**
     * @param int $databasePort
     */
    public function setDatabasePort($databasePort)
    {
        $this->databasePort = $databasePort;
    }

    /**
     * @return VolumeMount[]
     */
    public function getMounts()
    {
        return $this->mounts;
    }

    /**
     * @param VolumeMount[] $mounts
     */
    public function setMounts($mounts)
    {
        $this->mounts = $mounts;
    }

    /**
     * @return string
     */
    public function getPrefix()
    {
        return $this->prefix;
    }

    /**
     * @param string $prefix
     */
    public function setPrefix($prefix)
    {
        $this->prefix = $prefix;
    }
}