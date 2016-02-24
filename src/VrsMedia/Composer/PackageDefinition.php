<?php


namespace VrsMedia\Composer;


class PackageDefinition
{
    /**
     * @var string
     */
    private $name, $target;

    /**
     * @var bool
     */
    private $required;

    /**
     * PackageDefinition constructor.
     *
     * @param string $name
     * @param string $target
     * @param bool $required
     */
    public function __construct($name, $target, $required)
    {
        $this->name      = $name;
        $this->target      = $target;
        $this->required  = $required;
    }

    /**
     * @return string
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * @return string
     */
    public function getTarget()
    {
        return $this->target;
    }

    /**
     * @return bool
     */
    public function isRequired()
    {
        return $this->required;
    }
}