<?php

namespace VrsMedia\Phing;

/**
 * Represents a target from the phing build file
 */
class Target
{
    /**
     * @var string
     */
    private $name,
            $description;

    /**
     * Target constructor.
     *
     * @param string $name
     * @param string $description
     */
    public function __construct($name, $description)
    {
        $this->name        = $name;
        $this->description = $description;
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
    public function getDescription()
    {
        return $this->description;
    }

}