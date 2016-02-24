<?php


namespace VrsMedia\Composer\PackageValidator;


use Composer\Json\JsonFile;

class JSONValidator implements PackageValidatorInterface
{
    /**
     * @param string $packageName
     * @param string $directory
     *
     * @return bool
     */
    public function isValid($packageName, $directory)
    {
        $path = $this->getJSONPath($directory);

        if(!is_file($path)) {
            return false;
        }

        $config = $this->getJSONData($path);

        return $config['name'] == $packageName;
    }

    /**
     * @param string $directory
     *
     * @return string
     */
    private function getJSONPath($directory)
    {
        return $directory.'/composer.json';
    }

    /**
     * @param string $path
     *
     * @return mixed
     */
    private function getJSONData($path)
    {
        $json   = new JsonFile($path);
        $config = $json->read();

        return $config;
    }

}