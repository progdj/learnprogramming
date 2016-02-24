<?php


namespace VrsMedia\Composer;


use Composer\IO\IOInterface;
use Exception;
use VrsMedia\Composer\PackageValidator\CompositeValidator;
use VrsMedia\Composer\PackageValidator\DirectoryExistsValidator;
use VrsMedia\Composer\PackageValidator\JSONValidator;
use VrsMedia\Docker\VolumeMount;

class PackageResolver
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
     * @return VolumeMount[]
     * @throws Exception
     */
    public function resolvePackages($packages, $rootDirectory)
    {
        $io = &$this->io;
        $io->write('Please specify the absolute paths of your project packages.');
        $io->write('');
        $mounts = [];
        foreach ($packages as $package)
        {
            $name = $package->getName();

            $question  = sprintf("%s (%s): ", $name, $package->isRequired() ? 'required' : 'leave empty to skip');
            $validator = $this->getValidator($name, !$package->isRequired());

            try {
                if ($path = $io->askAndValidate($question, $validator, 3))
                {
                    $mounts[] = new VolumeMount($path, $package->getTarget());
                }
            }
            catch (Exception $failed)
            {
                if ($package->isRequired()) {
                    throw $failed;
                } else {
                    continue;
                }
            }
        }
        return $mounts;
    }

    /**
     * @param string $package
     * @param bool $allowEmpty
     * @return \Closure
     * @throws Exception
     */
    private function getValidator($package, $allowEmpty)
    {
        $validator = new CompositeValidator([
            new DirectoryExistsValidator(),
            new JSONValidator()
        ]);

        $errorMessage = sprintf('This is not the directory of the %s package', $package);

        return function ($path) use ($validator, $errorMessage, $package, $allowEmpty)
        {
            if ($allowEmpty && !$path)
            {
                return null;
            }

            $path = realpath($path);
            if (!$validator->isValid($package, $path))
            {
                throw new Exception($errorMessage);
            }

            return $path;
        };
    }
}