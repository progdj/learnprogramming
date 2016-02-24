<?php


namespace VrsMedia\Composer\PackageValidator;

interface PackageValidatorInterface
{
    /**
     * Validates that the given directory is valid for the specified package
     *
     * @param string $packageName
     * @param string $directory
     *
     * @return bool
     */
    public function isValid($packageName, $directory);
}