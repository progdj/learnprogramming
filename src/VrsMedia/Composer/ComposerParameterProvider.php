<?php

namespace VrsMedia\Composer;

use Composer\Composer;

class ComposerParameterProvider
{
    /**
     * @var Composer
     */
    private $composer;

    /**
     * @var ParameterDefinition
     */
    private $parameters;

    /**
     * ComposerOptionProvider constructor.
     *
     * @param Composer $composer
     */
    public function __construct(Composer $composer)
    {
        $this->composer = $composer;

        $parser = new ParameterParser();
        $this->parameters = $parser->parse($composer->getPackage()->getExtra());
    }

    /**
     * @return ParameterDefinition
     */
    public function getParameters()
    {
        return $this->parameters;
    }
}