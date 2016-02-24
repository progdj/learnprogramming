<?php


namespace VrsMedia\Composer\PackageValidator;


class DirectoryExistsValidator implements PackageValidatorInterface
{
    /**
     * @param string $packageName
     * @param string $directory
     *
     * @return bool
     */
    public function isValid($packageName, $directory)
    {
        return is_dir($directory);
    }
}