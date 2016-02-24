<?php


namespace VrsMedia\Composer;


use Composer\IO\IOInterface;
use Exception;
use VrsMedia\Composer\PackageValidator\CompositeValidator;
use VrsMedia\Composer\PackageValidator\DirectoryExistsValidator;
use VrsMedia\Composer\PackageValidator\JSONValidator;

class PackageLinker
{

    /**
     * @var IOInterface
     */
    private $io;

    /**
     * PackageLinker constructor.
     *
     * @param IOInterface $io
     */
    public function __construct(IOInterface $io)
    {
        $this->io = $io;
    }


    /**
     * @param        $packages PackageDefinition[]
     * @param string $rootDirectory
     *
     * @throws Exception
     */
    public function linkPackages($packages, $rootDirectory)
    {
        $io = &$this->io;
        $io->write('Please specify the absolute paths of your project packages.');
        $io->write('');

        foreach ($packages as $package)
        {
            $name = $package->getName();
            $link = $package->getLink();

            $question  = sprintf("%s: ", $name);
            $validator = $this->getValidator($name);

            $path = $io->askAndValidate($question, $validator);
            if(!symlink($path, $rootDirectory . '/' . $link)) {
                throw new \RuntimeException('Could not create symlink. Rerun as administrator');
            }
        }
    }

    /**
     * @param string $package
     *
     * @return \Closure
     * @throws Exception
     */
    private function getValidator($package)
    {
        $validator = new CompositeValidator([
            new DirectoryExistsValidator(),
            new JSONValidator()
        ]);

        $errorMessage = sprintf('This is not the directory of the %s package', $package);

        return function ($path) use ($validator, $errorMessage, $package)
        {
            if (!$validator->isValid($package, $path))
            {
                throw new Exception($errorMessage);
            }

            return $path;
        };
    }
}