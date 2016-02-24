<?php


namespace VrsMedia\Composer;


class PackageDefinition
{
    /**
     * @var string
     */
    private $name, $link;

    /**
     * PackageDefinition constructor.
     *
     * @param string $name
     * @param string $link
     */
    public function __construct($name, $link)
    {
        $this->name      = $name;
        $this->link      = $link;
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
    public function getLink()
    {
        return $this->link;
    }

}