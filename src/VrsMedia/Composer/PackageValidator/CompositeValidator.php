<?php


namespace VrsMedia\Composer\PackageValidator;


class CompositeValidator implements PackageValidatorInterface
{

    /**
     * @var PackageValidatorInterface[]
     */
    private $validators;

    /**
     * CompositeValidator constructor.
     *
     * @param PackageValidatorInterface[] $validators
     */
    public function __construct(array $validators)
    {
        $this->setValidators($validators);
    }

    /**
     * @param string $packageName
     * @param string $directory
     *
     * @return bool
     */
    public function isValid($packageName, $directory)
    {
        foreach ($this->validators as $validator)
        {
            if(!$validator->isValid($packageName, $directory)) {
                return false;
            }
        }

        return true;
    }

    /**
     * @param PackageValidatorInterface[] $validators
     */
    private function setValidators($validators)
    {
        $this->validateValidators($validators);
        $this->validators = $validators;
    }

    /**
     * @param $validators
     */
    private function validateValidators($validators)
    {
        foreach ($validators as $validator)
        {
            if (!$validator instanceof PackageValidatorInterface)
            {
                throw new \InvalidArgumentException();
            }
        }
    }

}