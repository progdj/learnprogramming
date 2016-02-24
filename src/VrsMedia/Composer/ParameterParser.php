<?php


namespace VrsMedia\Composer;


use Exception;

class ParameterParser
{
    const BUILD_FILE = 'build-file';
    const PACKAGES   = 'packages';

    const PACKAGE_NAME = 'name';
    const PACKAGE_LINK = 'link';

    /**
     * @param array $extraOptions
     *
     * @return ParameterDefinition
     */
    public function parse($extraOptions)
    {
        $this->validateExtraOptions($extraOptions);

        $buildFile = $this->getBuildFile($extraOptions);
        $packages  = $this->getPackageDefinitions($extraOptions);

        return new ParameterDefinition($buildFile, $packages);
    }

    /**
     * @param array $extraOptions
     *
     * @return PackageDefinition[]
     */
    private function getPackageDefinitions(array $extraOptions)
    {
        $packages = [];

        foreach ($extraOptions[self::PACKAGES] as $package)
        {
            $name = $package[self::PACKAGE_NAME];
            $link = $package[self::PACKAGE_LINK];

            $packages[] = new PackageDefinition($name, $link);
        }

        return $packages;
    }

    /**
     * Throws an exception
     */
    private function fail()
    {
        $message = 'Could not parse parameters';
        throw new Exception($message);
    }

    /**
     * @param $extraOptions
     *
     * @throws Exception
     */
    private function validateExtraOptions($extraOptions)
    {
        if (!is_array($extraOptions))
        {
            $this->fail();
        }

        if (!$this->hasParams($extraOptions)
        )
        {
            $this->fail();
        }

        if (!is_array($extraOptions[self::PACKAGES]))
        {
            $this->fail();
        }

        foreach ($extraOptions[self::PACKAGES] as $package)
        {
            if (!$this->isPackageDefinition($package))
            {
                $this->fail();
            }
        }
    }

    /**
     * @param array $extraOptions
     *
     * @return bool
     */
    private function hasParams(array $extraOptions)
    {
        return isset(
            $extraOptions[self::BUILD_FILE],
            $extraOptions[self::PACKAGES]
        );
    }

    /**
     * @param array $package
     *
     * @return bool
     */
    private function isPackageDefinition(array $package)
    {
        return isset(
            $package[self::PACKAGE_NAME],
            $package[self::PACKAGE_LINK]
        );
    }

    /**
     * @param array $extraOptions
     *
     * @return mixed
     */
    private function getBuildFile(array $extraOptions)
    {
        return $extraOptions[self::BUILD_FILE];
    }

}