<?php

namespace VrsMedia\Phing;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * Command that executes a phing target.
 */
class PhingCommand extends Command
{
    private $phing;
    private $task;
    private $description;

    /**
     * PhingCommand constructor.
     *
     * @param string $phing path to phing executable
     * @param string $task target to run
     * @param string $description phing task description
     */
    public function __construct($phing, $task, $description)
    {
        $this->phing = $phing;
        $this->task = $task;
        $this->description = $description;
        parent::__construct($task);
    }

    /**
     * @inheritdoc
     */
    public function run(InputInterface $input, OutputInterface $output)
    {
        passthru(sprintf('%s %s', $this->phing, $this->task));
    }

    /**
     * @inheritdoc
     */
    public function getDescription()
    {
        return $this->description;
    }
}