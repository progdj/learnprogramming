<?php


namespace VrsMedia\Composer;


use Composer\Composer;
use Composer\Factory;
use Composer\IO\ConsoleIO;
use Composer\IO\IOInterface;
use Composer\Util\ErrorHandler;
use Symfony\Component\Console\Application;
use Symfony\Component\Console\Helper\HelperSet;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Output\ConsoleOutputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use VrsMedia\Phing\PhingCommandFactory;

class Standalone extends Application
{

    private static $logo = '
   █████╗   ███╗   ███╗   █████╗   ██╗  ██╗  ███████╗  ██████╗
  ██╔══██╗  ████╗ ████║  ██╔══██╗  ██║ ██╔╝  ██╔════╝  ██╔══██╗
  ███████║  ██╔████╔██║  ███████║  █████╔╝   █████╗    ██████╔╝
  ██╔══██║  ██║╚██╔╝██║  ██╔══██║  ██╔═██╗   ██╔══╝    ██╔══██╗
  ██║  ██║  ██║ ╚═╝ ██║  ██║  ██║  ██║  ██╗  ███████╗  ██║  ██║
  ╚═╝  ╚═╝  ╚═╝     ╚═╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝  ╚══════╝  ╚═╝  ╚═╝
  VRSMedia GmbH & Co. KG
  ----------------------
';

    /**
     * @var IOInterface
     */
    protected $io;

    public function __construct()
    {
        parent::__construct('Amaker');
        $x = new Composer();
    }

    /**
     * {@inheritDoc}
     */
    public function run(InputInterface $input = null, OutputInterface $output = null)
    {
        if (null === $output) {
            $output = new ConsoleOutput(ConsoleOutput::VERBOSITY_NORMAL);
        }

        return parent::run($input, $output);
    }

    /**
     * {@inheritDoc}
     */
    public function doRun(InputInterface $input, OutputInterface $output)
    {
        $this->io = new ConsoleIO($input, $output, $this->getDefaultHelperSet());
        ErrorHandler::register($this->io);
        return parent::doRun($input, $output);
    }


    /**
     * @return IOInterface
     */
    public function getIO()
    {
        return $this->io;
    }

    /**
     * @return ComposerParameterProvider
     */
    public function getParameterProvider()
    {
        return new ComposerParameterProvider(Factory::create($this->getIO()));
    }

    public function getHelp()
    {
        return self::$logo . parent::getHelp();
    }

    /**
     * Initializes all the composer commands
     */
    protected function getDefaultCommands()
    {
        $commands = parent::getDefaultCommands();

        $phingCommands = new PhingCommandFactory(AMAKER_HOME . '/build.xml', AMAKER_HOME . '/bin/phing');
        $commands = array_merge($phingCommands->getCommands(), $commands);

        $commands[] = new ComposeConfigureCommand();


        return $commands;
    }
}