<?php


namespace VrsMedia\Database;


use Composer\IO\IOInterface;
use DateTime;

class ProgressPrinter
{
    /**
     * @var int
     */
    private $total = 0;

    /**
     * @var int
     */
    private $index = 0;

    /**
     * @var string
     */
    private $table = '';

    /**
     * @var IOInterface
     */
    private $io;

    /**
     * @var int
     */
    private $started = null;

    /**
     * ProgressPrinter constructor.
     *
     * @param IOInterface $io
     */
    public function __construct($io)
    {
        $this->io = $io;
    }

    /**
     * @param string $string
     * @param bool   $newline
     */
    public function write($string, $newline = true)
    {
        $this->io->write($string, $newline);
    }

    /**
     * @param int $total
     */
    public function setTotal($total)
    {
        $this->total = $total;
    }

    /**
     * @param string $table
     */
    public function setTable($table)
    {
        $this->table = $table;
    }

    public function increment()
    {
        static $lastPercent = null;
        static $lastTable = null;

        $refresh = false;

        $index = ++$this->index;

        $percent = floor((float)($index / $this->total) * 100);
        $message = $this->getProgressString($percent, $this->table);

        if($this->table != $lastTable || null === $lastTable) {
            $lastTable = $this->table;
            $refresh = true;
        }

        if ($percent > $lastPercent || null === $lastPercent)
        {
            $lastPercent = $percent;
            $refresh = true;
        }

        if ($refresh)
        {
            $this->io->overwrite($message, false);
        }
    }

    /**
     * @param int    $percent
     * @param string $table
     * @param string $estimatedTime
     *
     * @return string
     */
    private function getProgressString($percent, $table)
    {
        return sprintf("%3d %% (%s)", $percent, $table);
    }

    /**
     * @param int $seconds
     *
     * @return string
     */
    private function getSecondsAsETA($seconds)
    {
        $from = new DateTime();
        $to   = new DateTime("@$seconds");

        return $from->diff($to)->format('%i minutes and %s seconds left');
    }
}