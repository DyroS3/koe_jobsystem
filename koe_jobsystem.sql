SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";



CREATE TABLE `koe_jobsystem` (
  `id` int(250) NOT NULL,
  `identifier` varchar(46) DEFAULT NULL,
  `job` varchar(250) DEFAULT NULL,
  `grade` int(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


ALTER TABLE `koe_jobsystem`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `koe_jobsystem`
  MODIFY `id` int(250) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=380;
COMMIT;