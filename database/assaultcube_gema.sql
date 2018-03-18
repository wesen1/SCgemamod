-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 22. Feb 2017 um 08:46
-- Server-Version: 10.0.29-MariaDB-0ubuntu0.16.04.1
-- PHP-Version: 7.0.13-0ubuntu0.16.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `assaultcube_gema`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `account`
--

CREATE TABLE `account` (
  `id` int(11) NOT NULL,
  `name` int(11) NOT NULL,
  `password` text NOT NULL,
  `level` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `map`
--

CREATE TABLE `map` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `player`
--

CREATE TABLE `player` (
  `id` int(11) NOT NULL,
  `ip` int(11) NOT NULL,
  `name` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `player_ip`
--

CREATE TABLE `player_ip` (
  `id` int(11) NOT NULL,
  `ip` text NOT NULL,
  `account` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `player_name`
--

CREATE TABLE `player_name` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `record`
--

CREATE TABLE `record` (
  `id` int(11) NOT NULL,
  `time` int(11) NOT NULL,
  `timestamp` date NOT NULL,
  `time_remaining` int(11) NOT NULL,
  `weapon` int(11) NOT NULL,
  `map` int(11) NOT NULL,
  `player` int(11) DEFAULT NULL,
  `account` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `weapon`
--

CREATE TABLE `weapon` (
  `id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `name` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `weapon`
--

INSERT INTO `weapon` (`id`, `number`, `name`) VALUES
(1, 6, 'Assault Rifle'),
(2, 4, 'Submachine Gun'),
(3, 5, 'Sniper Rifle'),
(4, 3, 'Shotgun'),
(5, 2, 'Carbine');

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `account`
--
ALTER TABLE `account`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Indizes für die Tabelle `map`
--
ALTER TABLE `map`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `player`
--
ALTER TABLE `player`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ip` (`ip`),
  ADD KEY `name` (`name`);

--
-- Indizes für die Tabelle `player_ip`
--
ALTER TABLE `player_ip`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account` (`account`);

--
-- Indizes für die Tabelle `player_name`
--
ALTER TABLE `player_name`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `record`
--
ALTER TABLE `record`
  ADD PRIMARY KEY (`id`),
  ADD KEY `weapon_id` (`weapon`),
  ADD KEY `player_id` (`player`),
  ADD KEY `map_id` (`map`),
  ADD KEY `account` (`account`);

--
-- Indizes für die Tabelle `weapon`
--
ALTER TABLE `weapon`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `account`
--
ALTER TABLE `account`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT für Tabelle `map`
--
ALTER TABLE `map`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT für Tabelle `player`
--
ALTER TABLE `player`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;
--
-- AUTO_INCREMENT für Tabelle `player_ip`
--
ALTER TABLE `player_ip`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT für Tabelle `player_name`
--
ALTER TABLE `player_name`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT für Tabelle `record`
--
ALTER TABLE `record`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT für Tabelle `weapon`
--
ALTER TABLE `weapon`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `account`
--
ALTER TABLE `account`
  ADD CONSTRAINT `account_ibfk_1` FOREIGN KEY (`name`) REFERENCES `player_name` (`id`);

--
-- Constraints der Tabelle `player`
--
ALTER TABLE `player`
  ADD CONSTRAINT `player_ibfk_1` FOREIGN KEY (`ip`) REFERENCES `player_ip` (`id`),
  ADD CONSTRAINT `player_ibfk_2` FOREIGN KEY (`name`) REFERENCES `player_name` (`id`);

--
-- Constraints der Tabelle `player_ip`
--
ALTER TABLE `player_ip`
  ADD CONSTRAINT `player_ip_ibfk_1` FOREIGN KEY (`account`) REFERENCES `account` (`id`);

--
-- Constraints der Tabelle `record`
--
ALTER TABLE `record`
  ADD CONSTRAINT `record_ibfk_1` FOREIGN KEY (`weapon`) REFERENCES `weapon` (`id`),
  ADD CONSTRAINT `record_ibfk_2` FOREIGN KEY (`map`) REFERENCES `map` (`id`),
  ADD CONSTRAINT `record_ibfk_3` FOREIGN KEY (`player`) REFERENCES `player` (`id`),
  ADD CONSTRAINT `record_ibfk_4` FOREIGN KEY (`account`) REFERENCES `account` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
