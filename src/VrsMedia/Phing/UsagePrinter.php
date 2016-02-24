<?php


namespace VrsMedia\Phing;


class UsagePrinter
{
    /**
     * @var string[]
     */
    private $commands;

    /**
     * UsagePrinter constructor.
     *
     * @param string $buildFile
     */
    public function __construct($buildFile)
    {
        $this->parse($buildFile);
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
     * Print the help
     */
    public function output()
    {
        $this->printHeader();
        $this->printCommandList();
    }

    /**
     * Print a sexy header
     */
    private function printHeader()
    {
        echo <<<DOC
   █████╗   ███╗   ███╗   █████╗   ██╗  ██╗  ███████╗  ██████╗
  ██╔══██╗  ████╗ ████║  ██╔══██╗  ██║ ██╔╝  ██╔════╝  ██╔══██╗
  ███████║  ██╔████╔██║  ███████║  █████╔╝   █████╗    ██████╔╝
  ██╔══██║  ██║╚██╔╝██║  ██╔══██║  ██╔═██╗   ██╔══╝    ██╔══██╗
  ██║  ██║  ██║ ╚═╝ ██║  ██║  ██║  ██║  ██╗  ███████╗  ██║  ██║
  ╚═╝  ╚═╝  ╚═╝     ╚═╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝  ╚══════╝  ╚═╝  ╚═╝

VRSMedia GmbH & Co. KG
======================
Control the AMAK container via Phing build tool.

Usage: ./amaker COMMAND

Commands:

DOC;
    }

    /**
     * Print a list of available phing targets
     */
    private function printCommandList()
    {
        $format = $this->getCommandFormatString();

        foreach ($this->commands as $name => $description)
        {
            printf($format, $name, $description);
        }
    }

    /**
     * @return string
     */
    private function getCommandFormatString()
    {
        $longestCommand = $this->getLongestCommandLength();
        $format         = "    %-" . ($longestCommand + 3) . "s %s\n";

        return $format;
    }

    /**
     * Get the longest commands length to accurately arrange the commands
     *
     * @return int
     */
    private function getLongestCommandLength()
    {
        $commands = array_keys($this->commands);

        for ($i = 0, $longest = 0; $i < count($commands); ++$i)
        {
            $command = $commands[$i];
            $length  = strlen($command);

            if ($length > $longest)
            {
                $longest = $length;
            }
        }

        return $longest;
    }
}