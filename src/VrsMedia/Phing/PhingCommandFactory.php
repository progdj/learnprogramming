<?php


namespace VrsMedia\Phing;


class PhingCommandFactory
{
    /**
     * @var string[]
     */
    private $commands;

    /**
     * @var string
     */
    private $phing;

    /**
     * UsagePrinter constructor.
     *
     * @param string $buildFile
     * @param string $phing
     */
    public function __construct($buildFile, $phing)
    {
        $this->parse($buildFile);
        $this->phing = $phing;
    }

    /**
     * Read all targets from the build script
     *
     * @param string $buildFile
     */
    private function parse($buildFile)
    {
        $parser  = new ConfigurationParser($buildFile);
        $targets = $parser->getTargets();

        $commands = [];
        foreach ($targets as $target)
        {
            $name = $target->getName();
            $desc = $target->getDescription();

            $commands[$name] = $desc;
        }

        $this->commands = $commands;
    }

    /**
     * Get all included commands.
     *
     *
     */
    public function getCommands()
    {
        $commands = [];
        foreach ($this->commands as $target => $description)
        {
            $commands[] = new PhingCommand($this->phing, $target, $description);
        }

        return $commands;
    }
}