﻿-- phpMyAdmin SQL Dump
-- version 2.10.0.2
-- http://www.phpmyadmin.net
--
-- Počítač: localhost
-- Vygenerováno: Pondělí 15. září 2008, 21:59
-- Verze MySQL: 5.0.27
-- Verze PHP: 4.3.11RC1-dev

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Databáze: `rentmaster2_development`
--

-- --------------------------------------------------------

--
-- Struktura tabulky `accessories`
--

CREATE TABLE `accessories` (
  `id` int(11) NOT NULL auto_increment,
  `property_id` int(11) NOT NULL,
  `typ` enum('accessory','service') collate utf8_czech_ci NOT NULL default 'accessory',
  `name` varchar(30) collate utf8_czech_ci NOT NULL,
  `count` int(11) NOT NULL,
  `tarif` int(11) NOT NULL,
  `base` float NOT NULL,
  `tax` float NOT NULL,
  `price_with_tax` float NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci AUTO_INCREMENT=8 ;

--
-- Vypisuji data pro tabulku `accessories`
--

INSERT INTO `accessories` (`id`, `property_id`, `typ`, `name`, `count`, `tarif`, `base`, `tax`, `price_with_tax`) VALUES
(1, 5, 'accessory', 'vodoměr TUV', 1, 0, 9, 0, 9),
(2, 2, 'accessory', 'Vodměr TUV', 1, 0, 9, 0, 9),
(3, 2, 'accessory', 'Vodoměr SV', 1, 0, 9, 0, 9),
(4, 2, 'accessory', 'Měřící a regulační technika', 1, 0, 5, 0, 5),
(5, 2, 'service', 'Splátka družstevního podílu', 2, 0, 4053, 0, 4053),
(6, 5, 'service', 'elektřina', 3, 0, 69, 0, 69),
(7, 5, 'service', 'Odpap', 3, 0, 135, 0, 135);

-- --------------------------------------------------------

--
-- Struktura tabulky `added_penalties`
--

CREATE TABLE `added_penalties` (
  `id` int(11) NOT NULL auto_increment,
  `bill_id` int(11) NOT NULL,
  `penalty_id` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `count_generated_at` bigint(13) NOT NULL,
  `bill_is_paid` tinyint(1) NOT NULL,
  `sum` float default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci AUTO_INCREMENT=24 ;

--
-- Vypisuji data pro tabulku `added_penalties`
--

INSERT INTO `added_penalties` (`id`, `bill_id`, `penalty_id`, `count`, `count_generated_at`, `bill_is_paid`, `sum`) VALUES
(6, 90, 1, 14, 1221436800, 1, 1804.19),
(5, 90, 2, 9, 1221436800, 1, 1804.19),
(7, 48, 1, 10, 1221436800, 1, 1000),
(8, 91, 1, 4, 1221436800, 1, 0),
(9, 91, 4, 11, 1221436800, 1, 0),
(10, 96, 4, 3, 1221436800, 1, 0),
(11, 104, 3, 12, 1221436800, 1, 0),
(12, 127, 4, 2, 1221436800, 1, 0),
(13, 128, 3, 9, 1221436800, 1, 0),
(14, 134, 1, 8, 1221436800, 1, 990),
(15, 134, 4, 19, 1221436800, 1, 990),
(16, 135, 3, 47, 1221436800, 1, 1536.34),
(17, 216, 4, 35, 1221436800, 1, 350);

-- --------------------------------------------------------

--
-- Struktura tabulky `additionals`
--

CREATE TABLE `additionals` (
  `id` int(11) NOT NULL auto_increment,
  `owner` enum('renter','property') NOT NULL default 'property',
  `type_id` int(5) NOT NULL,
  `name` varchar(15) character set utf8 collate utf8_czech_ci NOT NULL,
  `content` varchar(25) character set utf8 collate utf8_czech_ci NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=24 ;

--
-- Vypisuji data pro tabulku `additionals`
--

INSERT INTO `additionals` (`id`, `owner`, `type_id`, `name`, `content`) VALUES
(4, 'property', 1, 'garáž', '2'),
(3, 'property', 5, 'Bytové jádro', 'původní­'),
(5, 'property', 1, 'Internet', 'LAN, WiFi'),
(6, 'property', 2, 'Internet', 'Zarizuje se'),
(8, 'property', 3, 'Tenisový kurt', 'antuka'),
(9, 'property', 3, 'Bazén', 'krytý'),
(10, 'property', 3, 'Internet', 'WiFi hot-spot'),
(19, 'property', 7, 'Internet', 'ADSL 6 Mbps'),
(14, 'renter', 1, 'Zaměstnání­', 'Manager'),
(15, 'renter', 1, 'Vystudoval', 'VŠE'),
(16, 'renter', 1, 'Auto', 'Opel Astra'),
(17, 'renter', 10, 'Zaměstnání', 'UK profesor FF'),
(18, 'renter', 10, 'WWW', 'www.stranka.cz'),
(20, 'renter', 2, 'Info', 'udaj'),
(21, 'property', 5, 'Internet', 'není'),
(22, 'renter', 12, 'Platby', 'casto meska s platbami'),
(23, 'renter', 11, 'Mistnost', 'loznice');

-- --------------------------------------------------------

--
-- Struktura tabulky `auto_pays`
--

CREATE TABLE `auto_pays` (
  `id` int(11) NOT NULL auto_increment,
  `renter_id` int(11) default '0',
  `property_id` int(11) default '0',
  `object` varchar(50) NOT NULL,
  `name` varchar(20) character set utf8 collate utf8_czech_ci default NULL,
  `price` int(11) default NULL,
  `category` varchar(7) NOT NULL,
  `groupp` varchar(12) default 'Extra',
  `last_pay` bigint(13) default '0',
  `end_pay` bigint(13) default NULL,
  `repeat` int(11) NOT NULL,
  `added` bigint(13) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=24 ;

--
-- Vypisuji data pro tabulku `auto_pays`
--

INSERT INTO `auto_pays` (`id`, `renter_id`, `property_id`, `object`, `name`, `price`, `category`, `groupp`, `last_pay`, `end_pay`, `repeat`, `added`) VALUES
(1, 0, 1, 'Odvoz odpadku', NULL, 400, 'out', 'poplatky', 1222642800, 0, 31, 1203977910),
(2, 0, 3, 'Zahradnik', NULL, 2000, 'out', 'poplatky', 1220137200, 0, 31, 1204070370),
(4, 7, 5, 'najem:(Slana)', NULL, 5400, 'in', 'najem', 1220482800, 0, 31, 1204484570),
(5, 9, 6, 'Najem(NovotnÃ½)', NULL, 5000, 'in', 'najem', 1208473200, 0, 14, 1204885332),
(6, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 'in', 'najem', 1222646400, 0, 7, 1206991839),
(7, 11, 5, 'Najem(Bacik)', NULL, 6000, 'in', 'najem', 1222473600, 1221004800, 7, 1207347037),
(8, 12, 5, 'Najem(Zelena)', NULL, 4500, 'in', 'najem', 1222473600, 0, 7, 1207347295),
(9, 1, 1, 'Rent(Marcin)', 'Nájem', 7500, 'in', 'najem', 1222732800, 0, 14, 1208606151),
(10, 2, 1, 'Rent(Novak)', NULL, 2700, 'in', 'najem', 1222300800, 1222819200, 7, 1208714851),
(11, 3, 2, 'Rent(Liska)', NULL, 7000, 'in', 'najem', 1222470000, 0, 7, 1208869661),
(12, 6, 3, 'Nájem(Novotna)', NULL, 11000, 'in', 'najem', 1220828400, 0, 31, 1216910521),
(13, 14, 7, 'Najem(Ferenc)', NULL, 13000, 'in', 'najem', 1222732800, 0, 1, 1218455717),
(14, 15, 7, 'Najem(Andrasy)', NULL, 11000, 'in', 'najem', 1220227200, 0, 31, 1218532577),
(17, 2, 1, 'Rent(Novak)', NULL, 6000, 'in', 'najem', 1222819200, NULL, 7, 1220795285),
(18, 11, 5, 'Najem(Bacik)', NULL, 7000, 'in', 'najem', 1222214400, NULL, 7, 1220895493),
(23, 5, 2, 'Nájem(Vesela)', NULL, 5000, 'in', 'najem', 1222387200, NULL, 14, 1221233545);

-- --------------------------------------------------------

--
-- Struktura tabulky `bank_accounts`
--

CREATE TABLE `bank_accounts` (
  `user_id` int(11) NOT NULL,
  `name` varchar(20) collate utf8_czech_ci NOT NULL,
  `antenumber` int(7) default NULL,
  `number` int(11) NOT NULL,
  `bank_code` int(5) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `bank_accounts`
--


-- --------------------------------------------------------

--
-- Struktura tabulky `bills`
--

CREATE TABLE `bills` (
  `id` int(11) NOT NULL auto_increment,
  `renter_id` int(11) default '0',
  `property_id` int(11) default '0',
  `object` varchar(50) NOT NULL,
  `name` varchar(20) default NULL,
  `price` int(11) NOT NULL default '0',
  `added_to_account` int(11) default '0',
  `penalty` int(11) default NULL,
  `category` varchar(7) NOT NULL,
  `groupp` varchar(12) default 'Extra',
  `paid` bigint(13) default '0',
  `paid_to` varchar(20) default 'cash',
  `deadline` bigint(13) NOT NULL,
  `repeat` int(3) default '0',
  `added` bigint(13) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=377 ;

--
-- Vypisuji data pro tabulku `bills`
--

INSERT INTO `bills` (`id`, `renter_id`, `property_id`, `object`, `name`, `price`, `added_to_account`, `penalty`, `category`, `groupp`, `paid`, `paid_to`, `deadline`, `repeat`, `added`) VALUES
(19, 2, 1, 'Rent_122007', NULL, 2700, 0, NULL, 'in', 'jine:auto', 1198108800, 'cash', 1198540800, 1, 1197072998),
(20, 3, 2, 'Rent_122007', NULL, 3000, 0, NULL, 'in', 'jine:motorka', 1198281600, 'cash', 1198540800, 1, 1197073129),
(21, 1, 1, 'Prva platba', NULL, 12000, 0, NULL, 'in', 'extra', 1198527200, 'cash', 1198627200, 1, 1197825355),
(23, 1, 1, 'druha platba', NULL, 2300, 0, NULL, 'in', 'extra', 1204329600, 'cash', 1198627200, 1, 1197826124),
(24, 1, 1, 'tretia platba', NULL, 12240, 0, NULL, 'out', 'extra', 1197926000, 'cash', 1197936000, 1, 1197827976),
(26, 3, 2, 'Rent_12008', NULL, 3000, 0, NULL, 'in', 'najem', 1204934400, 'cash', 1201219200, 1, 1199551710),
(27, 1, 1, 'Rent_12008', NULL, 3000, 0, NULL, 'in', 'najem', 1200787200, 'cash', 1201219200, 1, 1199551774),
(28, 2, 1, 'Rent_12008', NULL, 2700, 0, NULL, 'in', 'najem', 1201209200, 'cash', 1201219200, 1, 1199551775),
(31, 2, 1, 'testovanie selectu', NULL, 3, 0, NULL, 'out', 'Extra', 1204416000, 'cash', 1226966400, 1, 1199728240),
(32, 1, 1, 'Skuska prijmu a skupiny(poplatky)', NULL, 300, 1234597, NULL, 'in', 'Extra', 1207008000, 'cash', 1202169600, 4, 1200179611),
(33, 1, 1, 'Este raz a spravne aj so skupinou(poplatky)', NULL, 500, 0, NULL, 'in', 'poplatky', 1205539200, 'cash', 1214870400, 1, 1200179822),
(34, 4, 3, 'Prva platba Martiny', NULL, 2700, 8934, NULL, 'in', 'zaloha', 1204675200, 'cash', 1202342400, 1, 1200255345),
(35, 2, 1, 'Konrolna', NULL, 520, 111222444, NULL, 'in', 'penale', 1199404800, 'cash', 1199404800, 1, 1201302803),
(36, 4, 3, 'Dvere na balkon', NULL, 1250, 0, NULL, 'out', 'oprava', 1205539200, 'cash', 1201910400, 1, 1201374638),
(37, 4, 3, 'September 2007', NULL, 3400, 8934, NULL, 'in', 'najem', 1200960000, 'cash', 1201305600, 1, 1201374701),
(38, 3, 2, 'Kauce', NULL, 7000, 0, NULL, 'in', 'depozit', 1199232000, 'cash', 1201305600, 1, 1201374746),
(39, 3, 2, '3 mesiace neplatil', NULL, 4000, 0, NULL, 'in', 'penale', 0, 'cash', 1219276800, 1, 1201379003),
(40, 4, 3, 'poplatky zaloha', NULL, 10000, 0, NULL, 'in', 'poplatky', 1205452800, 'cash', 1227225600, 1, 1201379070),
(41, 4, 3, 'Bytove jadro', NULL, 11000, 0, NULL, 'in', 'oprava', 0, 'cash', 1224460800, 1, 1201379120),
(42, 2, 1, 'Prispevok na internet', NULL, 1000, 0, NULL, 'in', 'poplatky', 1205539200, 'cash', 1227225600, 1, 1201389333),
(43, 2, 1, 'Zaloha za garaz', NULL, 5000, 111222444, NULL, 'in', 'zaloha', 1202601600, 'cash', 1202774400, 1, 1201389371),
(44, 2, 1, 'unor 2008', NULL, 12000, 0, NULL, 'in', 'najem', 1200787200, 'cash', 1201305600, 1, 1201389452),
(45, 4, 3, '3x Pozdni platba', NULL, 1500, 8934, NULL, 'in', 'penale', 1207872000, 'cash', 1201564800, 1, 1201389506),
(46, 1, 1, 'Depozit', NULL, 3200, 1234597, NULL, 'in', 'depozit', 1207008000, 'cash', 1224288000, 1, 1201394328),
(47, 1, 1, 'Zaloha za brezen', NULL, 3700, 1234597, NULL, 'in', 'zaloha', 1219881600, 'cash', 1219017600, 1, 1201445256),
(48, 3, 2, 'Pozdni platba prosinec', NULL, 5300, 0, NULL, 'in', 'penale', 1209477936, 'cash', 1203292800, 1, 1201445298),
(49, 4, 3, 'Zaloha', NULL, 4000, 8934, NULL, 'in', 'depozit', 1201910400, 'cash', 1201910400, 1, 1201879025),
(52, 0, 3, 'Zaplaceno', NULL, 12, 0, NULL, 'out', 'poplatky', 1206576000, 'cash', 1201305600, 0, 1204065155),
(53, 1, 1, 'Zaplaceno2', NULL, 1234, 0, NULL, 'in', 'extra', 1204502400, 'cash', 1203984000, 0, 1204065280),
(54, 1, 1, 'render show', NULL, 120, 0, NULL, 'out', 'najem', 1205539200, 'cash', 1203984000, 0, 1204066822),
(55, 4, 0, 'Payed', NULL, 400, 0, NULL, 'out', 'extra', 1204502400, 'cash', 1204070400, 0, 1204071291),
(56, 2, 1, 'unor 2008', NULL, 12000, 0, NULL, 'in', 'najem', 1200787200, 'cash', 1201305600, 32, 1201389452),
(65, 0, 3, 'Bazen - udrzba', NULL, 300, 0, NULL, 'out', 'poplatky', 1206316800, 'cash', 1199750400, 7, 1204241579),
(66, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206451506, 'cash', 1200355200, 7, 1204241579),
(67, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206451517, 'cash', 1200960000, 7, 1204241579),
(68, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206451547, 'cash', 1201564800, 7, 1204241579),
(69, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206451560, 'cash', 1202169600, 7, 1204241579),
(70, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206452278, 'cash', 1202774400, 7, 1204241579),
(71, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206403200, 'cash', 1203379200, 7, 1204241579),
(72, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1203897600, 'cash', 1203984000, 7, 1204241579),
(76, 0, 3, 'zadano z nemovitosti', NULL, 9877, 0, NULL, 'in', 'najem', 1204502400, 'cash', 1204502400, 0, 1204565792),
(77, 0, 3, 'Navrat', NULL, 12345, 0, NULL, 'out', 'najem', 1204416000, 'cash', 1204502400, 0, 1204566498),
(78, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1207866441, 'cash', 1204588800, 7, 1204980682),
(79, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206230400, 'cash', 1205193600, 7, 1205270143),
(80, 0, 5, 'Rozbite okna po burke', NULL, 30500, 0, NULL, 'out', 'oprava', 1205193600, 'cash', 1205193600, 0, 1205193600),
(81, 0, 3, 'Bazen - udrzba', NULL, 1234, 0, NULL, 'out', 'poplatky', 1205452800, 'cash', 1199750400, 7, 1205514870),
(82, 1, 1, 'Zaloha za brezen', NULL, 800, 0, NULL, 'in', 'zaloha', 1205452800, 'cash', 1219017600, 1, 1205522162),
(83, 1, 1, 'Este raz a spravne aj so skupinou(poplatky)', NULL, 0, 0, NULL, 'in', 'poplatky', 1205539200, 'cash', 1214870400, 1, 1205586289),
(84, 1, 1, 'Este raz a spravne aj so skupinou(poplatky)', NULL, 0, 0, NULL, 'in', 'poplatky', 1205539200, 'cash', 1214870400, 1, 1205586385),
(85, 1, 1, 'Este raz a spravne aj so skupinou(poplatky)', NULL, 0, 0, NULL, 'in', 'poplatky', 1205539200, 'cash', 1214870400, 1, 1205587874),
(86, 1, 1, 'Este raz a spravne aj so skupinou(poplatky)', NULL, 0, 0, NULL, 'in', 'poplatky', 1205539200, 'cash', 1214870400, 1, 1205587924),
(87, 1, 1, 'Este raz a spravne aj so skupinou(poplatky)', NULL, 0, 0, NULL, 'in', 'poplatky', 1205539200, 'cash', 1214870400, 1, 1205587940),
(88, 1, 1, 'Este raz a spravne aj so skupinou(poplatky)', NULL, 0, 0, NULL, 'in', 'poplatky', 1205539200, 'cash', 1214870400, 1, 1205588444),
(89, 7, 0, 'Pridani penale', NULL, 1, 0, NULL, 'in', 'penale', 1205625600, 'cash', 1205625600, 0, 1205625600),
(90, 5, 2, 'Penale testing', NULL, 1927, 0, NULL, 'in', 'najem', 1216857600, 'cash', 1208304000, 0, 1205625600),
(91, 5, 2, 'Testovani vypoctu penale', NULL, 910, 0, NULL, 'in', 'oprava', 1207872000, 'cash', 1203206400, 0, 1205712000),
(92, 5, 2, 'Testovani vypoctu penale', NULL, 600, 0, NULL, 'in', 'oprava', 1206230400, 'cash', 1203206400, 0, 1206307034),
(93, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206577079, 'cash', 1205798400, 7, 1206307034),
(94, 0, 2, 'Oprava dveri', NULL, 1200, 0, NULL, 'out', 'oprava', 1206921600, 'cash', 1206921600, 0, 1206316800),
(95, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1206577079, 'cash', 1206403200, 7, 1206449719),
(96, 0, 2, 'Zmena kodu', NULL, 12000, 0, NULL, 'in', 'extra', 1206489600, 'cash', 1206489600, 0, 1206489600),
(98, 0, 2, 'ajax form 2', NULL, 3320, 0, NULL, 'out', 'oprava', 1206489600, 'cash', 1211760000, 0, 1206489600),
(99, 0, 2, 'ajax form 3', NULL, 3000, 0, NULL, 'out', 'oprava', 1206572987, 'cash', 1211760000, 0, 1206489600),
(100, 0, 2, 'ajax form 4 posledny!', NULL, 5000, 0, NULL, 'out', 'penale', 1206573341, 'cash', 1206576000, 0, 1206576000),
(101, 0, 5, 'MalovÃ¡nÃ­', NULL, 6000, 0, NULL, 'out', 'oprava', 1206921600, 'cash', 1206921600, 0, 1206576000),
(102, 0, 1, 'Odvoz odpadku', NULL, 400, 0, NULL, 'out', 'poplatky', 1206144000, 'cash', 1206576000, 31, 1206813269),
(103, 0, 3, 'Zahradnik', NULL, 2000, 0, NULL, 'out', 'poplatky', 1206489600, 'cash', 1206748800, 31, 1206813269),
(104, 10, 3, 'Testovanie % - penale', NULL, 126, 0, NULL, 'in', 'depozit', 1207872000, 'cash', 1205971200, 0, 1207008000),
(105, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1207008000, 'cash', 1207004400, 7, 1207152652),
(106, 7, 5, 'najem:(Slana)', NULL, 5400, 0, NULL, 'in', 'najem', 1207349397, 'cash', 1207090800, 31, 1207152652),
(107, 0, 1, 'Odvoz odpadku', NULL, 400, 0, NULL, 'out', 'poplatky', 1208822400, 'cash', 1209250800, 31, 1207160333),
(108, 0, 3, 'Zahradnik', NULL, 2000, 0, NULL, 'out', 'poplatky', 1216745460, 'cash', 1209423600, 31, 1207160333),
(109, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1207349398, 'cash', 1207609200, 7, 1207160333),
(110, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1207349398, 'cash', 1208214000, 7, 1207160333),
(111, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1216745460, 'cash', 1208818800, 7, 1207160333),
(112, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1216745461, 'cash', 1209423600, 7, 1207160333),
(113, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1207349398, 'cash', 1207526400, 7, 1207165635),
(114, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1207349398, 'cash', 1208131200, 7, 1207165635),
(115, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1208736000, 'cash', 1208736000, 7, 1207165636),
(116, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1216745460, 'cash', 1209340800, 7, 1207165636),
(117, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1207353600, 'cash', 1207958400, 7, 1207348517),
(118, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1208390400, 'cash', 1208563200, 7, 1207348517),
(119, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1208995200, 'cash', 1209168000, 7, 1207348517),
(120, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1207349398, 'cash', 1207958400, 7, 1207348517),
(121, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1208476800, 'cash', 1208563200, 7, 1207348517),
(122, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1208304000, 'cash', 1209168000, 7, 1207348518),
(123, 9, 6, 'Prva platba', NULL, 7300, 0, NULL, 'in', 'najem', 0, 'cash', 1209513600, 0, 1207699200),
(124, 9, 6, 'Najem(NovotnÃ½)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1206057600, 14, 1207699811),
(125, 9, 6, 'Najem(NovotnÃ½)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1207263600, 14, 1207699811),
(126, 9, 6, 'Najem(NovotnÃ½)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1208473200, 14, 1207699811),
(127, 3, 2, 'Penale testing', NULL, 1220, 543, NULL, 'in', 'poplatky', 1207872000, 'cash', 1207180800, 0, 1207872000),
(128, 12, 5, 'Debug', NULL, 3585, 0, NULL, 'in', 'extra', 1207785600, 'cash', 1207008000, 0, 1207872000),
(129, 4, 3, 'Bytove jadro', NULL, 11000, 0, NULL, 'in', 'oprava', 1207872000, 'cash', 1224460800, 1, 1207923145),
(130, 4, 3, 'Prva platba Martiny', NULL, 2300, 0, NULL, 'in', 'zaloha', 1208217600, 'cash', 1202342400, 1, 1208215479),
(131, 12, 5, 'Zniceny travnik po party', NULL, 3200, 0, NULL, 'out', 'jine', 1208908800, 'cash', 1209513600, 0, 1208217600),
(132, 1, 1, 'Rent(Marcin)', NULL, 3000, 1234597, NULL, 'in', 'najem', 1214524800, 'cash', 1208217600, 14, 1208606286),
(133, 1, 1, 'Rent(Marcin)', NULL, 3000, 1234597, NULL, 'in', 'najem', 1208822400, 'cash', 1209427200, 14, 1208606286),
(134, 7, 5, 'Nove penale', NULL, 1990, 0, NULL, 'in', 'penale', 1207612800, 'cash', 1207785600, 0, 1208563200),
(135, 2, 1, 'procenta penale', NULL, 2536, 111222444, NULL, 'in', 'penale', 1211846400, 'cash', 1207785600, 0, 1208563200),
(136, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1208217600, 'cash', 1208390400, 7, 1208714861),
(137, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1208995200, 'cash', 1208995200, 7, 1208714861),
(138, 0, 1, 'ZasklenÃ­ dveÅ™Ã­', NULL, 3400, 0, NULL, 'out', 'oprava', 1208822400, 'cash', 1208822400, 0, 1208822400),
(139, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1204934400, 'cash', 1204934400, 7, 1208869693),
(140, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1205366400, 'cash', 1205539200, 7, 1208869693),
(141, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1206057600, 'cash', 1206144000, 7, 1208869693),
(142, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1206748800, 'cash', 1206748800, 7, 1208869693),
(143, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 1217365060, 'cash', 1207350000, 7, 1208869693),
(144, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 1217365060, 'cash', 1207954800, 7, 1208869693),
(145, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 1217365060, 'cash', 1208559600, 7, 1208869693),
(146, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1209168000, 'cash', 1209164400, 7, 1208869693),
(147, 0, 3, 'a', NULL, 3, 0, NULL, 'in', 'najem', 1209168000, 'cash', 1209168000, 1, 1209238271),
(148, 0, 1, 'Odvoz odpadku', NULL, 400, 0, NULL, 'out', 'poplatky', 1211673600, 'cash', 1211929200, 31, 1209729493),
(149, 0, 3, 'Zahradnik', NULL, 2000, 0, NULL, 'out', 'poplatky', 1212105600, 'cash', 1212102000, 31, 1209729493),
(150, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1216745500, 'cash', 1210028400, 7, 1209729493),
(151, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1216745500, 'cash', 1210633200, 7, 1209729493),
(152, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1216745536, 'cash', 1211238000, 7, 1209729493),
(153, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1211587200, 'cash', 1211842800, 7, 1209729493),
(154, 7, 5, 'najem:(Slana)', NULL, 5400, 0, NULL, 'in', 'najem', 1209600000, 'cash', 1209769200, 31, 1209729493),
(155, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1216745500, 'cash', 1209945600, 7, 1209729493),
(156, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1216745500, 'cash', 1210550400, 7, 1209729493),
(157, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1216745536, 'cash', 1211155200, 7, 1209729493),
(158, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1216745536, 'cash', 1211760000, 7, 1209729493),
(159, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1209945600, 'cash', 1209772800, 7, 1209729494),
(160, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1210204800, 'cash', 1210377600, 7, 1209729494),
(161, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1210982400, 'cash', 1210982400, 7, 1209729494),
(162, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1211587200, 'cash', 1211587200, 7, 1209729494),
(163, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1212192000, 'cash', 1212192000, 7, 1209729494),
(164, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1209772800, 'cash', 1209772800, 7, 1209729494),
(165, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1210377600, 'cash', 1210377600, 7, 1209729494),
(166, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1217350405, 'cash', 1210982400, 7, 1209729494),
(167, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1217350405, 'cash', 1211587200, 7, 1209729494),
(168, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1217350405, 'cash', 1212192000, 7, 1209729494),
(169, 1, 1, 'Rent(Marcin)', NULL, 3000, 1234597, NULL, 'in', 'najem', 1210550400, 'cash', 1210636800, 14, 1209729494),
(170, 1, 1, 'Rent(Marcin)', NULL, 3000, 1234597, NULL, 'in', 'najem', 1211414400, 'cash', 1211846400, 14, 1209729494),
(171, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1209859200, 'cash', 1209600000, 7, 1209729494),
(172, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1209686400, 'cash', 1210204800, 7, 1209729494),
(173, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1212364800, 'cash', 1210809600, 7, 1209729494),
(174, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1211328000, 'cash', 1211414400, 7, 1209729494),
(175, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1217203200, 'cash', 1212019200, 7, 1209729494),
(176, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1209772800, 'cash', 1209769200, 7, 1209729494),
(177, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1210377600, 'cash', 1210374000, 7, 1209729494),
(178, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1210982400, 'cash', 1210978800, 7, 1209729494),
(179, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1211587200, 'cash', 1211583600, 7, 1209729494),
(180, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1212192000, 'cash', 1212188400, 7, 1209729494),
(181, 7, 5, 'Posledna platba', NULL, 260, 0, NULL, 'in', 'extra', 0, 'cash', 1214092800, 0, 1213056000),
(182, 0, 1, 'Odvoz odpadku', NULL, 400, 0, NULL, 'out', 'poplatky', 1214611200, 'cash', 1214607600, 31, 1214487457),
(183, 0, 3, 'Zahradnik', NULL, 2000, 0, NULL, 'out', 'poplatky', 1214784000, 'cash', 1214780400, 31, 1214487458),
(184, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1212451200, 'cash', 1212447600, 7, 1214487458),
(185, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1213056000, 'cash', 1213052400, 7, 1214487458),
(186, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1213660800, 'cash', 1213657200, 7, 1214487458),
(187, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1214265600, 'cash', 1214262000, 7, 1214487458),
(188, 7, 5, 'najem:(Slana)', NULL, 5400, 0, NULL, 'in', 'najem', 1212451200, 'cash', 1212447600, 31, 1214487458),
(189, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1212364800, 'cash', 1212364800, 7, 1214487458),
(190, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1212969600, 'cash', 1212969600, 7, 1214487458),
(191, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1213574400, 'cash', 1213574400, 7, 1214487458),
(192, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1214179200, 7, 1214487458),
(193, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1214784000, 7, 1214487458),
(194, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1212796800, 'cash', 1212796800, 7, 1214487458),
(195, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1213401600, 'cash', 1213401600, 7, 1214487459),
(196, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1214006400, 'cash', 1214006400, 7, 1214487459),
(197, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1214611200, 'cash', 1214611200, 7, 1214487459),
(198, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1217350405, 'cash', 1212796800, 7, 1214487459),
(199, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1213401600, 'cash', 1213401600, 7, 1214487459),
(200, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1214006400, 'cash', 1214006400, 7, 1214487459),
(201, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1214611200, 'cash', 1214611200, 7, 1214487459),
(202, 1, 1, 'Rent(Marcin)', NULL, 3000, 1234597, NULL, 'in', 'najem', 1212969600, 'cash', 1213056000, 14, 1214487459),
(203, 1, 1, 'Rent(Marcin)', NULL, 3000, 1234597, NULL, 'in', 'najem', 1214438400, 'cash', 1214265600, 14, 1214487459),
(204, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1212624000, 'cash', 1212624000, 7, 1214487459),
(205, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1213228800, 'cash', 1213228800, 7, 1214487459),
(206, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1213833600, 'cash', 1213833600, 7, 1214487459),
(207, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1214438400, 'cash', 1214438400, 7, 1214487459),
(208, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1212796800, 'cash', 1212793200, 7, 1214487459),
(209, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1213401600, 'cash', 1213398000, 7, 1214487459),
(210, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1214006400, 'cash', 1214002800, 7, 1214487460),
(211, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1214611200, 'cash', 1214607600, 7, 1214487460),
(212, 0, 1, 'Januar', NULL, 1000, 0, NULL, 'out', 'oprava', 1217116800, 'cash', 1217116800, 0, 1214524800),
(213, 0, 1, 'Nova platba', NULL, 1234, 0, NULL, 'out', 'extra', 1212278400, 'cash', 1212278400, 12, 1214564272),
(214, 0, 1, 'Nova platba', NULL, 1234, 0, NULL, 'out', 'extra', 1213315200, 'cash', 1213315200, 12, 1214564281),
(216, 7, 5, 'Dalsi test penale', NULL, 2350, 0, NULL, 'in', 'poplatky', 1212278400, 'cash', 1212278400, 0, 1214524800),
(217, 0, 1, 'Odvoz odpadku', NULL, 400, 0, NULL, 'out', 'poplatky', 0, 'cash', 1217286000, 31, 1215031248),
(218, 0, 3, 'Zahradnik', NULL, 2000, 0, NULL, 'out', 'poplatky', 0, 'cash', 1217458800, 31, 1215031248),
(219, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1214870400, 'cash', 1214866800, 7, 1215031248),
(220, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1215475200, 'cash', 1215471600, 7, 1215031248),
(221, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 0, 'cash', 1216076400, 7, 1215031248),
(222, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 0, 'cash', 1216681200, 7, 1215031248),
(223, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 0, 'cash', 1217286000, 7, 1215031248),
(224, 7, 5, 'najem:(Slana)', NULL, 5400, 0, NULL, 'in', 'najem', 0, 'cash', 1215126000, 31, 1215031248),
(225, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1215388800, 7, 1215031248),
(226, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1215993600, 7, 1215031248),
(227, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1216598400, 7, 1215031249),
(228, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1217203200, 7, 1215031249),
(229, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1215216000, 'cash', 1215216000, 7, 1215031249),
(230, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1215820800, 7, 1215031249),
(231, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1216425600, 7, 1215031249),
(232, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1217030400, 7, 1215031249),
(233, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1215216000, 'cash', 1215216000, 7, 1215031249),
(234, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1215820800, 'cash', 1215820800, 7, 1215031249),
(235, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1216425600, 7, 1215031249),
(236, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1217030400, 7, 1215031249),
(237, 1, 1, 'Rent(Marcin)', NULL, 3000, 1234597, NULL, 'in', 'najem', 1215388800, 'cash', 1215475200, 14, 1215031249),
(238, 1, 1, 'Rent(Marcin)', NULL, 3000, 1234597, NULL, 'in', 'najem', 1216684800, 'cash', 1216684800, 14, 1215031249),
(239, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1215043200, 'cash', 1215043200, 7, 1215031249),
(240, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1215648000, 'cash', 1215648000, 7, 1215031249),
(241, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1216252800, 'cash', 1216252800, 7, 1215031249),
(242, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1216857600, 'cash', 1216857600, 7, 1215031249),
(243, 2, 1, 'Rent(Novak)', NULL, 2700, 111222444, NULL, 'in', 'najem', 1217462400, 'cash', 1217462400, 7, 1215031249),
(244, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1215216000, 'cash', 1215212400, 7, 1215031250),
(245, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1215820800, 'cash', 1215817200, 7, 1215031250),
(246, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1216422000, 7, 1215031250),
(247, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1217026800, 7, 1215031250),
(248, 6, 3, 'Nájem(Novotna)', NULL, 11000, 0, NULL, 'in', 'najem', 1204761600, 'cash', 1204761600, 31, 1217363877),
(249, 6, 3, 'Nájem(Novotna)', NULL, 11000, 0, NULL, 'in', 'najem', 1207440000, 'cash', 1207436400, 31, 1217363877),
(250, 6, 3, 'Nájem(Novotna)', NULL, 11000, 0, NULL, 'in', 'najem', 1210118400, 'cash', 1210114800, 31, 1217363877),
(251, 6, 3, 'Nájem(Novotna)', NULL, 11000, 0, NULL, 'in', 'najem', 1212796800, 'cash', 1212793200, 31, 1217363877),
(252, 6, 3, 'Nájem(Novotna)', NULL, 11000, 0, NULL, 'in', 'najem', 1215475200, 'cash', 1215471600, 31, 1217363877),
(253, 0, 1, 'Odvoz odpadku', NULL, 400, 0, NULL, 'out', 'poplatky', 0, 'cash', 1219964400, 31, 1217595276),
(254, 0, 3, 'Zahradnik', NULL, 2000, 0, NULL, 'out', 'poplatky', 0, 'cash', 1220137200, 31, 1217595283),
(255, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 0, 'cash', 1217890800, 7, 1217595288),
(256, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 0, 'cash', 1218495600, 7, 1217595288),
(257, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 0, 'cash', 1219100400, 7, 1217595288),
(258, 0, 3, 'Bazen - udrzba', NULL, 1500, 0, NULL, 'out', 'poplatky', 1220550436, 'cash', 1219705200, 7, 1217595288),
(259, 7, 5, 'najem:(Slana)', NULL, 5400, 0, NULL, 'in', 'najem', 0, 'cash', 1217804400, 31, 1217595288),
(260, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1217808000, 7, 1217595288),
(261, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1218412800, 7, 1217595288),
(262, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1219017600, 7, 1217595288),
(263, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219622400, 7, 1217595288),
(264, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1217635200, 7, 1217595288),
(265, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1218240000, 7, 1217595288),
(266, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1218844800, 7, 1217595288),
(267, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219449600, 7, 1217595288),
(268, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1220054400, 7, 1217595288),
(269, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1217635200, 7, 1217595288),
(270, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1218240000, 7, 1217595288),
(271, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1218844800, 7, 1217595288),
(272, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219449600, 7, 1217595289),
(273, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1220054400, 7, 1217595289),
(274, 1, 1, 'Rent(Marcin)', 'Nájem', 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1217894400, 14, 1217595289),
(275, 1, 1, 'Rent(Marcin)', 'Nájem', 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1219104000, 14, 1217595289),
(276, 2, 1, 'Rent(Novak)', NULL, 2700, 0, NULL, 'in', 'najem', 0, 'cash', 1218067200, 7, 1217595289),
(277, 2, 1, 'Rent(Novak)', NULL, 2700, 0, NULL, 'in', 'najem', 0, 'cash', 1218672000, 7, 1217595289),
(278, 2, 1, 'Rent(Novak)', NULL, 2700, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219276800, 7, 1217595289),
(279, 2, 1, 'Rent(Novak)', NULL, 2700, 0, NULL, 'in', 'najem', 0, 'cash', 1219881600, 7, 1217595289),
(280, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1217631600, 7, 1217595289),
(281, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1218236400, 7, 1217595289),
(282, 3, 2, 'Rent(Liska)', NULL, 3000, 543, NULL, 'in', 'najem', 1218844800, 'cash', 1218841200, 7, 1217595289),
(283, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219446000, 7, 1217595289),
(284, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1220050800, 7, 1217595289),
(285, 6, 3, 'Nájem(Novotna)', NULL, 11000, 0, NULL, 'in', 'najem', 1218153600, 'cash', 1218150000, 31, 1217595289),
(286, 15, 7, 'Najem(Andrasy)', NULL, 11000, 0, NULL, 'in', 'najem', 0, 'cash', 1217548800, 31, 1218532577),
(287, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1218499200, 'cash', 1218499200, 1, 1219482111),
(288, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1218585600, 'cash', 1218585600, 1, 1219482111),
(289, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1218672000, 'cash', 1218672000, 1, 1219482111),
(290, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1218758400, 'cash', 1218758400, 1, 1219482111),
(291, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1218844800, 'cash', 1218844800, 1, 1219482111),
(292, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1218931200, 'cash', 1218931200, 1, 1219482111),
(293, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1219017600, 'cash', 1219017600, 1, 1219482111),
(294, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1219104000, 'cash', 1219104000, 1, 1219482111),
(295, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1219190400, 'cash', 1219190400, 1, 1219482111),
(296, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1219276800, 'cash', 1219276800, 1, 1219482111),
(297, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219363200, 1, 1219482111),
(298, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219449600, 1, 1219482111),
(299, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219536000, 1, 1219482111),
(300, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219622400, 1, 1219482111),
(301, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220550436, 'cash', 1219708800, 1, 1219482111),
(302, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1219795200, 'cash', 1219795200, 1, 1219482111),
(303, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1219881600, 'cash', 1219881600, 1, 1219482111),
(304, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1219968000, 'cash', 1219968000, 1, 1219482111),
(305, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220054400, 'cash', 1220054400, 1, 1219482112),
(306, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220140800, 'cash', 1220140800, 1, 1219482112),
(307, 1, 1, 'Informace', NULL, 250, 1234597, NULL, 'in', 'extra', 1220140800, 'cash', 1220140800, 0, 1219622400),
(308, 1, 1, 'Informace', NULL, 100, 0, NULL, 'in', 'extra', 1220140800, 'cash', 1220140800, 0, 1219678443),
(309, 0, 1, 'Odvoz odpadku', NULL, 400, 0, NULL, 'out', 'poplatky', 0, 'cash', 1222642800, 31, 1220283987),
(310, 7, 5, 'najem:(Slana)', NULL, 5400, 0, NULL, 'in', 'najem', 0, 'cash', 1220482800, 31, 1220283987),
(311, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1220227200, 7, 1220283987),
(312, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1220832000, 7, 1220283987),
(313, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1221436800, 7, 1220283987),
(314, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1222041600, 7, 1220283987),
(315, 10, 3, 'Najem(MlÃ½nek)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1222646400, 7, 1220283987),
(316, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1220659200, 7, 1220283987),
(317, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1221264000, 7, 1220283987),
(318, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1221868800, 7, 1220283987),
(319, 11, 5, 'Najem(Bacik)', NULL, 6000, 0, NULL, 'in', 'najem', 0, 'cash', 1222473600, 7, 1220283987),
(320, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1220659200, 7, 1220283987),
(321, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1221264000, 7, 1220283987),
(322, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1221868800, 7, 1220283987),
(323, 12, 5, 'Najem(Zelena)', NULL, 4500, 0, NULL, 'in', 'najem', 0, 'cash', 1222473600, 7, 1220283987),
(324, 1, 1, 'Rent(Marcin)', 'Nájem', 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1220313600, 14, 1220283988),
(325, 1, 1, 'Rent(Marcin)', 'Nájem', 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1221523200, 14, 1220283988),
(326, 1, 1, 'Rent(Marcin)', 'Nájem', 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1222732800, 14, 1220283988),
(327, 2, 1, 'Rent(Novak)', NULL, 2700, 0, NULL, 'in', 'najem', 0, 'cash', 1220486400, 7, 1220283988),
(328, 2, 1, 'Rent(Novak)', NULL, 2700, 0, NULL, 'in', 'najem', 0, 'cash', 1221091200, 7, 1220283988),
(329, 2, 1, 'Rent(Novak)', NULL, 2700, 0, NULL, 'in', 'najem', 0, 'cash', 1221696000, 7, 1220283988),
(330, 2, 1, 'Rent(Novak)', NULL, 2700, 0, NULL, 'in', 'najem', 0, 'cash', 1222300800, 7, 1220283988),
(331, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1220655600, 7, 1220283988),
(332, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1221260400, 7, 1220283988),
(333, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1221865200, 7, 1220283988),
(334, 3, 2, 'Rent(Liska)', NULL, 3000, 0, NULL, 'in', 'najem', 0, 'cash', 1222470000, 7, 1220283988),
(335, 6, 3, 'Nájem(Novotna)', NULL, 11000, 0, NULL, 'in', 'najem', 1220832000, 'cash', 1220828400, 31, 1220283988),
(336, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220227200, 'cash', 1220227200, 1, 1220283988),
(337, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220313600, 'cash', 1220313600, 1, 1220283988),
(338, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220400000, 'cash', 1220400000, 1, 1220283988),
(339, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 1220486400, 'cash', 1220486400, 1, 1220283988),
(340, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1220572800, 1, 1220283988),
(341, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1220659200, 1, 1220283988),
(342, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1220745600, 1, 1220283989),
(343, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1220832000, 1, 1220283989),
(344, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1220918400, 1, 1220283989),
(345, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221004800, 1, 1220283989),
(346, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221091200, 1, 1220283989),
(347, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221177600, 1, 1220283989),
(348, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221264000, 1, 1220283989),
(349, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221350400, 1, 1220283989),
(350, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221436800, 1, 1220283989),
(351, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221523200, 1, 1220283989),
(352, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221609600, 1, 1220283989),
(353, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221696000, 1, 1220283989),
(354, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221782400, 1, 1220283989),
(355, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221868800, 1, 1220283989),
(356, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1221955200, 1, 1220283989),
(357, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222041600, 1, 1220283989),
(358, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222128000, 1, 1220283989),
(359, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222214400, 1, 1220283989),
(360, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222300800, 1, 1220283990),
(361, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222387200, 1, 1220283990),
(362, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222473600, 1, 1220283990),
(363, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222560000, 1, 1220283990),
(364, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222646400, 1, 1220283990),
(365, 14, 7, 'Najem(Ferenc)', NULL, 13000, 0, NULL, 'in', 'najem', 0, 'cash', 1222732800, 1, 1220283990),
(366, 15, 7, 'Najem(Andrasy)', NULL, 11000, 0, NULL, 'in', 'najem', 0, 'cash', 1220227200, 31, 1220283990),
(367, 1, 1, 'Zaloha za brezen', NULL, 400, 0, NULL, 'in', 'zaloha', 1219017600, 'cash', 1219017600, 1, 1220288615),
(368, 11, 5, 'Najem(Bacik)', NULL, 7000, 0, NULL, 'in', 'najem', 0, 'cash', 1221609600, 7, 1220896208),
(369, 11, 5, 'Najem(Bacik)', NULL, 7000, 0, NULL, 'in', 'najem', 0, 'cash', 1222214400, 7, 1220896208),
(372, 5, 2, 'Nájem(Vesela)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1218758400, 14, 1221233546),
(373, 5, 2, 'Nájem(Vesela)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1219968000, 14, 1221233546),
(374, 5, 2, 'Nájem(Vesela)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1221177600, 14, 1221233546),
(375, 5, 2, 'Nájem(Vesela)', NULL, 5000, 0, NULL, 'in', 'najem', 0, 'cash', 1222387200, 14, 1221233559),
(376, 7, 5, 'Posledna platba', NULL, 1000, 0, NULL, 'in', 'extra', 1214092800, 'cash', 1214092800, 0, 1221490550);

-- --------------------------------------------------------

--
-- Struktura tabulky `contacts`
--

CREATE TABLE `contacts` (
  `id` int(4) NOT NULL auto_increment,
  `user_id` int(5) NOT NULL,
  `typ` enum('contact','administrator') collate utf8_czech_ci NOT NULL default 'contact',
  `name` varchar(30) collate utf8_czech_ci NOT NULL,
  `profesion` varchar(30) collate utf8_czech_ci NOT NULL,
  `address` varchar(50) collate utf8_czech_ci NOT NULL,
  `telephone1` int(11) NOT NULL,
  `telephone2` int(11) default NULL,
  `email` varchar(35) collate utf8_czech_ci NOT NULL,
  `website` varchar(30) collate utf8_czech_ci NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci AUTO_INCREMENT=9 ;

--
-- Vypisuji data pro tabulku `contacts`
--

INSERT INTO `contacts` (`id`, `user_id`, `typ`, `name`, `profesion`, `address`, `telephone1`, `telephone2`, `email`, `website`) VALUES
(1, 1, 'contact', 'PRE', 'Elektřina', 'Jindrišská 12\r\nPraha 1\r\n11000', 2, NULL, 'pre@pre.cz', 'www.pre.cz'),
(2, 1, 'contact', 'Vodo a.s.', 'Voda', 'Nejaka ulice 6\r\nMesto\r\n12345', 123456, NULL, '', ''),
(3, 1, 'administrator', 'Bytové družstvo J.R.', 'owner', 'Jeremianova 2\r\n10033 Zlin', 777234255, 2147483647, 'bdjr@bdjr.cz', 'www.bdjr.cz'),
(4, 1, 'administrator', 'Centra a.s.', 'administrator', 'Mickiewiczova 2\r\n10233 Praha', 735556355, 2147483647, 'centra@centra.cz', 'www.cetra.cz'),
(0, 0, 'contact', '', '', '', 0, 0, '', ''),
(6, 1, 'administrator', 'Koleje a menzy', 'owner', 'Adresa v Prahe 534\r\nPraha', 123456789, 987654321, 'kam@kam.cuni.cz', 'www.kam.cuni.cz'),
(7, 1, 'contact', 'U:fon', 'ISP', 'Havlickova 53\r\nPraha', 2147483647, 2147483647, 'ufon@ufon.cz', 'www.ufon.cz'),
(8, 1, 'contact', 'PlynPro', 'plynárenství', 'Jozefova 32\r\n123 00 Praha', 65234434, 0, 'pp@plyn.cz', 'www.plyn.cz');

-- --------------------------------------------------------

--
-- Struktura tabulky `contacts_properties`
--

CREATE TABLE `contacts_properties` (
  `property_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `contacts_properties`
--

INSERT INTO `contacts_properties` (`property_id`, `contact_id`) VALUES
(3, 1),
(3, 2),
(1, 7),
(7, 2),
(7, 7),
(2, 2),
(1, 7),
(1, 8);

-- --------------------------------------------------------

--
-- Struktura tabulky `fittings`
--

CREATE TABLE `fittings` (
  `id` int(11) NOT NULL auto_increment,
  `property_id` int(3) NOT NULL,
  `name` varchar(20) NOT NULL,
  `model` varchar(15) default 'model',
  `serial` varchar(20) default '0',
  `price` int(6) NOT NULL,
  `count` int(3) default '1',
  `about` varchar(200) character set utf8 collate utf8_czech_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=23 ;

--
-- Vypisuji data pro tabulku `fittings`
--

INSERT INTO `fittings` (`id`, `property_id`, `name`, `model`, `serial`, `price`, `count`, `about`) VALUES
(1, 1, 'Zidle', 'student', '0', 800, 1, 'Zidle je jenom jedna v obyvaku. Je koleckova, cerna a je nova. čšř'),
(2, 2, 'Stul', 'ikea', '0', 300, 1, NULL),
(3, 3, 'Lustr', 'palacino', '0', 4500, 1, NULL),
(4, 3, 'stul', 'ieka', 'SE53245', 2, 2, NULL),
(5, 2, 'Policka', 'drevena', '214662', 340, 4, NULL),
(6, 3, 'Skrin', 'rolldoor', '234', 8000, 3, NULL),
(7, 1, 'botnik', 'ikea', '456', 120, 1, NULL),
(9, 1, 'TV', 'sony', '', 22000, 1, NULL),
(10, 1, 'Postel', 'manzelska', '', 12000, 1, NULL),
(11, 1, 'koberec', 'svetly', '', 5000, 3, NULL),
(12, 3, 'Bazen', 'venkovni', '', 59000, 1, NULL),
(13, 3, 'Palma', 'kytka', '', 2000, 3, NULL),
(14, 1, 'Automat', 'cafe', '', 40000, 3, NULL),
(15, 2, 'Postel', 'manzelska', '', 7000, 1, 'Manzelska postel siroka 160cm. Drevena s matraci.'),
(16, 2, 'Stul', 'jidelny', '', 5900, 1, 'Jidelni stul do kuchyne. Dreveny, 1,5 x 0,7 m.'),
(17, 2, 'SedaÄka', 'limit', '', 14000, 1, 'Rohova sedacka. Textil.'),
(18, 5, 'Postel', 'manzelska 160cm', '', 7000, 1, 'Drevena postel, tmavy mahagon. S matraci Kalio.'),
(19, 5, 'Matrac', 'Kalio', '', 11000, 1, 'Matrac k manzelske posteli. Nova, zakoupena leden 2008'),
(20, 3, 'LedniÄka', 'AEG', '', 9800, 1, 'Zakoupena v roce 2008. Zaruka 10 let. BÃ­la, 80 litrÅ¯. Rozmery VxSxH = 180x70x50 cm'),
(21, 5, 'PraÄka', 'AEG', '', 8000, 1, 'ZÃ¡ruka 10 let. 30 l, rozmery 60x60x80 cm'),
(22, 7, 'Stul - mramor', 'DaVinci', '1234', 54000, 1, '');

-- --------------------------------------------------------

--
-- Struktura tabulky `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `from_id` int(11) NOT NULL,
  `to_id` int(11) NOT NULL,
  `replied_to` int(11) default '0',
  `subject` varchar(50) character set utf8 collate utf8_czech_ci NOT NULL,
  `content` varchar(500) character set utf8 collate utf8_czech_ci NOT NULL,
  `sent_at` bigint(13) NOT NULL,
  `read` bigint(13) default '0',
  `new` tinyint(1) default '1',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=26 ;

--
-- Vypisuji data pro tabulku `messages`
--

INSERT INTO `messages` (`id`, `from_id`, `to_id`, `replied_to`, `subject`, `content`, `sent_at`, `read`, `new`) VALUES
(1, 1, 3, 0, 'Test', 'PRva sprava na test send.', 1217005866, 1, 0),
(2, 1, 3, 0, 'Zprava 2', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec rhoncus dapibus dolor. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin ornare varius arcu. Donec ornare. Phasellus nec arcu. Cras nec ligula ac sapien tempus interdum. Donec nec leo.', 1217066238, 1, 0),
(3, 1, 3, 0, 'Dluh', 'Vazeny najemniku, kde dni 27.7.2008 mate 21 600 CZK. Prosim uhradte danou castku do konce mesice.', 1217148484, 1217148484, 0),
(4, 1, 4, 0, 'Privitanie', 'Vitajte v aplikaci rentmaster. Pre lepšiu bezpečnost doporučujeme zmenit prihlasovacie heslo, pripadne login.\r\n\r\nPrajeme pekny den\r\nTeam rentmaster', 1217162500, 1217350778, 0),
(5, 1, 3, 0, 'Ajax', 'Zmenili sme posielanie správ na Ajax requesty. Toto je test.', 1217163711, 1217163711, 0),
(6, 1, 4, 0, 'Ajax', 'Zmenili sme posielanie správ na Ajax requesty. Toto je test.', 1217163773, 1217350765, 0),
(7, 1, 4, 0, 'Span testing', 'Pridal som span s textom o uspesnom poslani spravy. toto je test.', 1217166293, 1217350744, 0),
(8, 3, 1, 3, 'RE:Dluh', 'DObre dobre, zaplatim.', 1217281014, 1217281014, 0),
(9, 3, 1, 2, 'RE:Zprava 2', 'Ipsum sipsum klasika - Phasellus nec arcu. Cras nec ligula ac sapien tempus interdum. Donec nec leo.', 1217281341, 1217348301, 0),
(10, 3, 1, 1, 'RE:Test', 'Test send prebiehol v poradku, sprav prisla.', 1217281367, 1217350018, 0),
(11, 3, 1, 5, 'RE:Ajax', 'Tento test je tiez v poriadku. Posielam test odpoved. Tak cau.', 1217281416, 1217348289, 0),
(12, 3, 1, 3, 'RE:Dluh', 'A este by som si pak prosil zaslat rozpis na dalsi mesiac. Dik.', 1217281466, 1217340995, 0),
(13, 1, 3, 0, 'Ajax', 'Zmenili sme posielanie správ na Ajax requesty. Toto je test.', 1217345422, 1217345514, 0),
(14, 1, 6, 0, 'Privitanie', 'Vitajte v aplikaci rentmaster. Pre lepšiu bezpečnost doporučujeme zmenit prihlasovacie heslo, pripadne login.\n\nPrajeme pekny den\nTeam rentmaster', 1217346961, 1217348019, 0),
(15, 1, 6, 0, 'Dalsia sprava', 'Toto je dalsia testovacia sprava na kontrolu konektivity.', 1217347759, 1217349852, 0),
(16, 1, 3, 9, 'RE:RE:Zprava 2', 'Neposielaj mi zbytocne blbe odpovede.', 1217348324, 1217423456, 0),
(17, 1, 3, 10, 'RE:RE:Test', 'Dakujem za odozvu.', 1217350030, 0, 1),
(18, 4, 1, 7, 'RE:Span testing', 'Testy mi neposielajte, nie som laboratorna mys.', 1217350759, 1217350898, 0),
(19, 4, 1, 6, 'RE:Ajax', 'Uz ziadne testz sakra!', 1217350776, 1217362982, 0),
(20, 4, 1, 4, 'RE:Privitanie', 'Dobre, ale este neviem ako na to, tak s tym nieco urobte. Nazdar.', 1217350801, 1217362946, 0),
(21, 1, 3, 0, 'Najomne', 'Nezaplatene najomne od 5.6.08! Ak do tyzdna nezaplatite, predcasne ukoncujem zmluvu!', 1217540852, 1217540947, 0),
(24, 1, 10, 0, 'Pozdrav', 'Dobry den,\r\n\r\nVasi platbu jsem dostal. Dekuji.\r\n\r\nPreji hezky den', 1219580785, 1219580815, 0),
(25, 1, 4, 0, 'Dalsia sprava', 'Posielam dalsiu spravu.\r\nMusime zmenit zobrazvanie\r\naby bolo vidiet aj nove riadky.', 1219678187, 0, 1),
(23, 3, 1, 0, 'Platby za červenec', 'Dorby den, platby na červenec budu meškat, každá asi 3 dni. Omlouvam se za potíže. s pozdravem Michal Novák', 1217593708, 1221381161, 0);

-- --------------------------------------------------------

--
-- Struktura tabulky `notes`
--

CREATE TABLE `notes` (
  `id` int(11) NOT NULL auto_increment,
  `type_id` int(4) default NULL,
  `owner` enum('renter','property','bill') collate utf8_czech_ci default NULL,
  `content` varchar(160) collate utf8_czech_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci AUTO_INCREMENT=45 ;

--
-- Vypisuji data pro tabulku `notes`
--

INSERT INTO `notes` (`id`, `type_id`, `owner`, `content`, `created_at`, `updated_at`) VALUES
(1, 2, 'property', 'Nova poznamka(enum)', '2008-03-03 16:58:58', '2008-03-03 16:58:58'),
(4, 2, 'property', 'druha nova', '2008-03-03 17:02:38', '2008-03-03 17:02:38'),
(5, 6, 'property', 'Prva', '2008-03-07 11:54:05', '2008-03-07 11:54:05'),
(6, 81, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-14 18:15:09', '2008-03-14 18:15:09'),
(7, 65, 'bill', '', '2008-03-14 18:15:24', '2008-08-01 15:01:27'),
(8, 82, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-14 20:16:02', '2008-03-14 20:16:02'),
(9, 47, 'bill', 'ÄŒÃ¡steÄne splaceno 800 dne 1.1.1970', '2008-03-14 20:16:03', '2008-03-14 20:16:03'),
(10, 83, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-15 14:04:50', '2008-03-15 14:04:50'),
(12, 84, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-15 14:06:25', '2008-03-15 14:06:25'),
(14, 85, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-15 14:31:14', '2008-03-15 14:31:14'),
(16, 86, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-15 14:32:04', '2008-03-15 14:32:04'),
(18, 87, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-15 14:32:20', '2008-03-15 14:32:20'),
(20, 88, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-15 14:40:44', '2008-03-15 14:40:44'),
(22, 92, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-03-23 22:17:14', '2008-03-23 22:17:14'),
(23, 91, 'bill', 'ÄŒÃ¡steÄne splaceno 600 dne 1.1.1970', '2008-03-23 22:17:14', '2008-03-23 22:17:14'),
(24, 65, 'bill', 'PÅ™iÄteno penÃ¡le 34,- CZK', '2008-03-24 19:01:47', '2008-03-24 19:01:47'),
(25, 104, 'bill', 'PÅ™iÄteno penÃ¡le 26,- CZK', '2008-04-11 00:31:17', '2008-04-11 00:31:17'),
(26, 91, 'bill', 'PÅ™iÄteno penÃ¡le 510,- CZK', '2008-04-11 13:38:57', '2008-04-11 13:38:57'),
(27, 127, 'bill', 'PÅ™iÄteno penÃ¡le 20,- CZK', '2008-04-11 13:42:39', '2008-04-11 13:42:39'),
(28, 128, 'bill', 'PÅ™iÄteno penÃ¡le 585,- CZK', '2008-04-11 14:28:15', '2008-04-11 14:28:15'),
(29, 41, 'bill', 'ÄŒÃ¡steÄne splaceno 11000 CZK dne 11.4.2008', '2008-04-11 16:12:24', '2008-04-11 16:12:24'),
(30, 129, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-04-11 16:12:25', '2008-04-11 16:12:25'),
(31, 34, 'bill', 'ÄŒÃ¡steÄne splaceno 2300 CZK dne 15.4.2008', '2008-04-15 01:24:39', '2008-04-15 01:24:39'),
(32, 130, 'bill', 'ÄŒÃ¡steÄnÃ¡ splÃ¡tka', '2008-04-15 01:24:39', '2008-04-15 01:24:39'),
(33, 48, 'bill', 'PÅ™iÄteno penÃ¡le 1000.0,- CZK', '2008-04-29 16:05:30', '2008-04-29 16:05:30'),
(34, 135, 'bill', 'PÅ™iÄteno penÃ¡le 1536,- CZK', '2008-05-27 22:23:47', '2008-05-27 22:23:47'),
(35, 134, 'bill', 'Přičteno penále 990,- CZK', '2008-06-08 22:09:21', '2008-06-08 22:09:21'),
(36, 90, 'bill', 'Přičteno penále 1804,- CZK', '2008-07-24 16:55:51', '2008-07-24 16:55:51'),
(37, 307, 'bill', 'Částečne splaceno 100 CZK dne 31.08.2008', '2008-08-25 17:34:03', '2008-08-25 17:34:03'),
(38, 308, 'bill', 'Částečná splátka', '2008-08-25 17:34:03', '2008-08-25 17:34:03'),
(39, 1, 'property', 'telefon: 20 45 638 12', '2008-08-26 17:51:40', '2008-08-26 17:51:40'),
(40, 47, 'bill', 'Částečne splaceno 400 CZK dne 18.08.2008', '2008-09-01 19:03:35', '2008-09-01 19:03:35'),
(41, 367, 'bill', 'Částečná splátka', '2008-09-01 19:03:35', '2008-09-01 19:03:35'),
(42, 216, 'bill', 'Přičteno penále 350,- CZK', '2008-09-15 16:44:41', '2008-09-15 16:44:41'),
(43, 181, 'bill', 'Částečne splaceno 1000 CZK dne 22.06.2008', '2008-09-15 16:55:50', '2008-09-15 16:55:50'),
(44, 376, 'bill', 'Částečná splátka', '2008-09-15 16:55:50', '2008-09-15 16:55:50');

-- --------------------------------------------------------

--
-- Struktura tabulky `owners`
--

CREATE TABLE `owners` (
  `id` int(11) NOT NULL auto_increment,
  `company` int(11) default NULL,
  `name` varchar(150) character set utf8 collate utf8_czech_ci NOT NULL,
  `address` varchar(100) NOT NULL,
  `phone` int(11) NOT NULL,
  `phone2` int(11) default NULL,
  `fax` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Vypisuji data pro tabulku `owners`
--

INSERT INTO `owners` (`id`, `company`, `name`, `address`, `phone`, `phone2`, `fax`) VALUES
(1, NULL, 'Michal', '', 776682653, NULL, NULL);

-- --------------------------------------------------------

--
-- Struktura tabulky `penalties`
--

CREATE TABLE `penalties` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `name` varchar(20) collate utf8_czech_ci NOT NULL,
  `after` int(4) NOT NULL,
  `price` int(6) NOT NULL,
  `percent` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci AUTO_INCREMENT=7 ;

--
-- Vypisuji data pro tabulku `penalties`
--

INSERT INTO `penalties` (`id`, `user_id`, `name`, `after`, `price`, `percent`) VALUES
(1, 1, 'Pozdní­ nájem', 7, 100, 0),
(2, 1, 'Měškání 10 dní', 10, 5, 1),
(3, 1, 'Denně 2 procenta', 1, 2, 1),
(4, 1, 'Měškání­ 3 dny', 3, 10, 0),
(5, 2, 'Najem-měškání 7dni', 7, 200, 0),
(6, 1, '5 dni - 5%', 5, 5, 1);

-- --------------------------------------------------------

--
-- Struktura tabulky `penalty_histories`
--

CREATE TABLE `penalty_histories` (
  `bill_id` int(11) NOT NULL,
  `date_added` bigint(13) NOT NULL,
  `old_penalty_sum` int(11) NOT NULL,
  `new_penalty_sum` int(11) NOT NULL,
  `action_performed` varchar(50) collate utf8_czech_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `penalty_histories`
--

INSERT INTO `penalty_histories` (`bill_id`, `date_added`, `old_penalty_sum`, `new_penalty_sum`, `action_performed`) VALUES
(134, 1208044800, 0, 10, 'Měškání­ 3 dny'),
(134, 1208304000, 10, 20, 'Měškání­ 3 dny'),
(134, 1208390400, 20, 120, 'Pozdní­ nájem'),
(134, 1208563200, 120, 130, 'Měškání­ 3 dny'),
(48, 1203897600, 0, 100, 'Pozdní­ nájem'),
(48, 1204502400, 100, 200, 'Pozdní­ nájem'),
(48, 1205107200, 200, 300, 'Pozdní­ nájem'),
(48, 1205712000, 300, 400, 'Pozdní­ nájem'),
(48, 1206316800, 400, 500, 'Pozdní­ nájem'),
(48, 1206918000, 500, 600, 'Pozdní­ nájem'),
(48, 1207522800, 600, 700, 'Pozdní­ nájem'),
(48, 1208127600, 700, 800, 'Pozdní­ nájem'),
(135, 1207872000, 0, 20, 'Denně 2 procenta'),
(135, 1207958400, 20, 40, 'Denně 2 procenta'),
(135, 1208044800, 40, 61, 'Denně 2 procenta'),
(135, 1208131200, 61, 82, 'Denně 2 procenta'),
(135, 1208217600, 82, 104, 'Denně 2 procenta'),
(135, 1208304000, 104, 126, 'Denně 2 procenta'),
(135, 1208390400, 126, 148, 'Denně 2 procenta'),
(135, 1208476800, 148, 171, 'Denně 2 procenta'),
(135, 1208563200, 171, 195, 'Denně 2 procenta'),
(135, 1208649600, 195, 218, 'Denně 2 procenta'),
(48, 1208732400, 800, 900, 'Pozdní­ nájem'),
(135, 1208649600, 218, 243, 'Denně 2 procenta'),
(135, 1208736000, 243, 268, 'Denně 2 procenta'),
(135, 1208822400, 268, 293, 'Denně 2 procenta'),
(135, 1208908800, 293, 319, 'Denně 2 procenta'),
(134, 1208822400, 130, 140, 'Měškání­ 3 dny'),
(90, 1208908800, 0, 100, 'Pozdní­ nájem'),
(135, 1208995200, 319, 345, 'Denně 2 procenta'),
(135, 1209081600, 345, 372, 'DennÄ› 2 procenta'),
(134, 1208995200, 140, 240, 'PozdnÃ­ nÃ¡jem'),
(134, 1209081600, 240, 250, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(90, 1209168000, 100, 111, 'MÄ›Å¡kÃ¡nÃ­  10 dnÃ­'),
(135, 1209168000, 372, 400, 'DennÄ› 2 procenta'),
(135, 1209254400, 400, 428, 'DennÄ› 2 procenta'),
(134, 1209340800, 250, 260, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(48, 1209337200, 900, 1000, 'PozdnÃ­ nÃ¡jem'),
(135, 1209340800, 428, 456, 'DennÄ› 2 procenta'),
(135, 1209427200, 456, 485, 'DennÄ› 2 procenta'),
(135, 1209513600, 485, 515, 'DennÄ› 2 procenta'),
(135, 1209600000, 515, 545, 'DennÄ› 2 procenta'),
(134, 1209600000, 260, 360, 'PozdnÃ­ nÃ¡jem'),
(134, 1209600000, 360, 370, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(90, 1209513600, 111, 211, 'PozdnÃ­ nÃ¡jem'),
(135, 1209686400, 545, 576, 'DennÄ› 2 procenta'),
(135, 1209772800, 576, 608, 'DennÄ› 2 procenta'),
(135, 1209859200, 608, 640, 'DennÄ› 2 procenta'),
(134, 1209859200, 370, 380, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(135, 1209945600, 640, 673, 'DennÄ› 2 procenta'),
(135, 1210032000, 673, 706, 'DennÄ› 2 procenta'),
(135, 1210118400, 706, 741, 'DennÄ› 2 procenta'),
(135, 1210204800, 741, 775, 'DennÄ› 2 procenta'),
(135, 1210291200, 775, 811, 'DennÄ› 2 procenta'),
(135, 1210377600, 811, 847, 'DennÄ› 2 procenta'),
(135, 1210464000, 847, 884, 'DennÄ› 2 procenta'),
(135, 1210550400, 884, 922, 'DennÄ› 2 procenta'),
(135, 1210636800, 922, 960, 'DennÄ› 2 procenta'),
(135, 1210723200, 960, 999, 'DennÄ› 2 procenta'),
(135, 1210809600, 999, 1039, 'DennÄ› 2 procenta'),
(135, 1210896000, 1039, 1080, 'DennÄ› 2 procenta'),
(135, 1210982400, 1080, 1122, 'DennÄ› 2 procenta'),
(135, 1211068800, 1122, 1164, 'DennÄ› 2 procenta'),
(135, 1211155200, 1164, 1208, 'DennÄ› 2 procenta'),
(134, 1210118400, 380, 390, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(134, 1210204800, 390, 490, 'PozdnÃ­ nÃ¡jem'),
(134, 1210377600, 490, 500, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(134, 1210636800, 500, 510, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(134, 1210809600, 510, 610, 'PozdnÃ­ nÃ¡jem'),
(134, 1210896000, 610, 620, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(134, 1211155200, 620, 630, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(90, 1210032000, 211, 227, 'MÄ›Å¡kÃ¡nÃ­  10 dnÃ­'),
(90, 1210118400, 227, 327, 'PozdnÃ­ nÃ¡jem'),
(90, 1210723200, 327, 427, 'PozdnÃ­ nÃ¡jem'),
(90, 1210896000, 427, 455, 'MÄ›Å¡kÃ¡nÃ­  10 dnÃ­'),
(135, 1211241600, 1208, 1252, 'DennÄ› 2 procenta'),
(135, 1211328000, 1252, 1297, 'DennÄ› 2 procenta'),
(135, 1211414400, 1297, 1343, 'DennÄ› 2 procenta'),
(135, 1211500800, 1343, 1390, 'DennÄ› 2 procenta'),
(135, 1211587200, 1390, 1437, 'DennÄ› 2 procenta'),
(135, 1211673600, 1437, 1486, 'DennÄ› 2 procenta'),
(135, 1211760000, 1486, 1536, 'DennÄ› 2 procenta'),
(134, 1211414400, 630, 730, 'PozdnÃ­ nÃ¡jem'),
(134, 1211414400, 730, 740, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(134, 1211673600, 740, 750, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(90, 1211328000, 455, 555, 'PozdnÃ­ nÃ¡jem'),
(90, 1211760000, 555, 589, 'MÄ›Å¡kÃ¡nÃ­  10 dnÃ­'),
(134, 1211932800, 750, 760, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(134, 1212019200, 760, 860, 'PozdnÃ­ nÃ¡jem'),
(134, 1212192000, 860, 870, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(134, 1212451200, 870, 880, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(134, 1212624000, 880, 980, 'PozdnÃ­ nÃ¡jem'),
(134, 1212710400, 980, 990, 'MÄ›Å¡kÃ¡nÃ­ 3 dny'),
(90, 1211932800, 589, 689, 'PozdnÃ­ nÃ¡jem'),
(90, 1212537600, 689, 789, 'PozdnÃ­ nÃ¡jem'),
(90, 1212624000, 789, 834, 'MÄ›Å¡kÃ¡nÃ­  10 dnÃ­'),
(90, 1213142400, 834, 934, 'PozdnÃ­ nÃ¡jem'),
(90, 1213488000, 934, 987, 'MÄ›Å¡kÃ¡nÃ­  10 dnÃ­'),
(90, 1213747200, 987, 1087, 'PozdnÃ­ nÃ¡jem'),
(90, 1214352000, 1087, 1148, 'MÄ›Å¡kÃ¡nÃ­  10 dnÃ­'),
(90, 1214352000, 1148, 1248, 'PozdnÃ­ nÃ¡jem'),
(216, 1212537600, 0, 10, 'Měškání­ 3 dny'),
(216, 1212796800, 10, 20, 'Měškání­ 3 dny'),
(216, 1213056000, 20, 30, 'Měškání­ 3 dny'),
(216, 1213315200, 30, 40, 'Měškání­ 3 dny'),
(216, 1213574400, 40, 50, 'Měškání­ 3 dny'),
(216, 1213833600, 50, 60, 'Měškání­ 3 dny'),
(216, 1214092800, 60, 70, 'Měškání­ 3 dny'),
(216, 1214352000, 70, 80, 'Měškání­ 3 dny'),
(216, 1214611200, 80, 90, 'Měškání­ 3 dny'),
(216, 1214870400, 90, 100, 'Měškání­ 3 dny'),
(216, 1215129600, 100, 110, 'Měškání­ 3 dny'),
(216, 1215388800, 110, 120, 'Měškání­ 3 dny'),
(216, 1215648000, 120, 130, 'Měškání­ 3 dny'),
(216, 1215907200, 130, 140, 'Měškání­ 3 dny'),
(216, 1216166400, 140, 150, 'Měškání­ 3 dny'),
(216, 1216425600, 150, 160, 'Měškání­ 3 dny'),
(216, 1216684800, 160, 170, 'Měškání­ 3 dny'),
(90, 1214956800, 1248, 1348, 'Pozdní­ nájem'),
(90, 1215216000, 1348, 1421, 'Měškání 10 dní'),
(90, 1215561600, 1421, 1521, 'Pozdní­ nájem'),
(90, 1216080000, 1521, 1604, 'Měškání 10 dní'),
(90, 1216166400, 1604, 1704, 'Pozdní­ nájem'),
(90, 1216771200, 1704, 1804, 'Pozdní­ nájem'),
(216, 1216944000, 170, 180, 'Měškání­ 3 dny'),
(216, 1217203200, 180, 190, 'Měškání­ 3 dny'),
(216, 1217462400, 190, 200, 'Měškání­ 3 dny'),
(216, 1217721600, 200, 210, 'Měškání­ 3 dny'),
(216, 1217980800, 210, 220, 'Měškání­ 3 dny'),
(216, 1218240000, 220, 230, 'Měškání­ 3 dny'),
(216, 1218499200, 230, 240, 'Měškání­ 3 dny'),
(216, 1218758400, 240, 250, 'Měškání­ 3 dny'),
(216, 1219017600, 250, 260, 'Měškání­ 3 dny'),
(216, 1219276800, 260, 270, 'Měškání­ 3 dny'),
(216, 1219536000, 270, 280, 'Měškání­ 3 dny'),
(216, 1219795200, 280, 290, 'Měškání­ 3 dny'),
(216, 1220054400, 290, 300, 'Měškání­ 3 dny'),
(216, 1220313600, 300, 310, 'Měškání­ 3 dny'),
(216, 1220572800, 310, 320, 'Měškání­ 3 dny'),
(216, 1220832000, 320, 330, 'Měškání­ 3 dny'),
(216, 1221091200, 330, 340, 'Měškání­ 3 dny'),
(216, 1221350400, 340, 350, 'Měškání­ 3 dny');

-- --------------------------------------------------------

--
-- Struktura tabulky `precepts`
--

CREATE TABLE `precepts` (
  `auto_pay_id` int(11) NOT NULL,
  `object` varchar(30) character set utf8 collate utf8_czech_ci NOT NULL,
  `price` int(11) NOT NULL,
  PRIMARY KEY  (`auto_pay_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Vypisuji data pro tabulku `precepts`
--


-- --------------------------------------------------------

--
-- Struktura tabulky `properties`
--

CREATE TABLE `properties` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(3) NOT NULL,
  `user1_renter_id` int(11) default NULL,
  `user2_renter_id` int(11) default '0',
  `address` varchar(50) character set utf8 collate utf8_czech_ci NOT NULL,
  `owner_id` int(11) default '0',
  `administrator_id` int(11) default '0',
  `cadaster` varchar(100) character set utf8 collate utf8_czech_ci default NULL,
  `building` varchar(50) character set utf8 collate utf8_czech_ci default NULL,
  `house` varchar(20) character set utf8 collate utf8_czech_ci default NULL,
  `flat` int(6) default NULL,
  `floor` int(3) NOT NULL,
  `floors` int(3) default NULL,
  `space_arrangement` varchar(10) character set utf8 collate utf8_czech_ci NOT NULL,
  `cathegory` varchar(10) character set utf8 collate utf8_czech_ci default NULL,
  `room_height` float default NULL,
  `chimneys` int(2) default NULL,
  `heating` varchar(40) character set utf8 collate utf8_czech_ci NOT NULL,
  `bathroom` varchar(40) character set utf8 collate utf8_czech_ci NOT NULL,
  `wc` varchar(40) character set utf8 collate utf8_czech_ci NOT NULL,
  `warm_water` varchar(40) character set utf8 collate utf8_czech_ci NOT NULL,
  `city` varchar(25) character set utf8 collate utf8_czech_ci NOT NULL,
  `psc` int(5) NOT NULL,
  `name` varchar(25) character set utf8 collate utf8_czech_ci NOT NULL,
  `rent` int(8) NOT NULL,
  `fees` int(8) NOT NULL,
  `bedrooms` int(2) NOT NULL,
  `social_rooms` varchar(15) character set utf8 collate utf8_czech_ci NOT NULL default '0',
  `about` varchar(400) character set utf8 collate utf8_czech_ci NOT NULL,
  `area` int(5) NOT NULL,
  `locality` varchar(25) character set utf8 collate utf8_czech_ci NOT NULL,
  `photo` varchar(80) character set utf8 collate utf8_czech_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Vypisuji data pro tabulku `properties`
--

INSERT INTO `properties` (`id`, `user_id`, `user1_renter_id`, `user2_renter_id`, `address`, `owner_id`, `administrator_id`, `cadaster`, `building`, `house`, `flat`, `floor`, `floors`, `space_arrangement`, `cathegory`, `room_height`, `chimneys`, `heating`, `bathroom`, `wc`, `warm_water`, `city`, `psc`, `name`, `rent`, `fees`, `bedrooms`, `social_rooms`, `about`, `area`, `locality`, `photo`) VALUES
(1, 1, 0, 0, 'Na Vetrniku 12', 0, 0, 'Pet?iny', 'B3', 'B3', 31, 0, 3, '4 + kk', '2', 0, 0, '', '', '', '', 'Praha', 16200, 'Vetrnik', 2200, 4000, 4, '01101010', 'K dlouhodobÃ©mu pronÃ¡jmu nezaÅ™Ã­zenÃ½ byt 3 1 o velikosti 98m2,2 balkony 6 4m na P3 ve 4pat?e.Do centra 5min.MoÅ¾nost pronÃ¡jmu v objektu parkovacÃ­ho stÃ¡nÃ­ i skladovÃ½ch prostor.CelÃ½ objekt je po rekonstrukci,byt pÅ™ipraven k nastÄ›hovÃ¡nÃ­.NezaÅ™Ã­zenÃ½.KompletnÄ› vybavenÃ¡ kuchynÄ›.', 100, 'Petriny', ''),
(2, 1, 0, 0, 'KRakovska 12', 3, 4, 'Stare Mesto', '3122', '12', 16, 0, 5, '3 + 1', '2', 2.1, 1, 'Ustředni topení - dálkové', 'vlastní v bytě', 'Vlasntí v bytě splachovací', 'Centrální', 'Praha', 12345, 'Byt 2', 20000, 3000, 3, '00101101', 'Byt na tÅ™etÃ­m patÅ™e v 4 patrovÃ©m panelÃ¡ku. Bez vytahu. Byt je orientovany na zapad, takze odpoledne je prosviceny. Bytove jadro po rekonstrukci. Dlazba v predsini. Jinde koberce.', 80, 'Nove Mesto', ''),
(3, 1, 0, 0, 'Za humny 24', 3, 0, '', '', '', 0, 0, 0, '', '', 0, 0, '', '', '', '', 'Praha', 13900, 'Vila', 50000, 20000, 12, '11011101', 'Dlhy text o Vile, ktoru s tu chcem spravovat, aby som mal lepsi prehlad. Je v nej plno miesta a je velka. Treba tam ubytovat vela ludi. Tak dufam, ze sa to vsetko podari.', 300, '', ''),
(4, 0, 0, 0, 'none', 0, 0, '', '', '', 0, 0, 0, '', '', 0, 0, '', '', '', '', 'none', 0, 'none', 0, 0, 0, '0', '', 0, '', NULL),
(5, 1, 0, 0, 'Sládkovičova  23', 3, 3, 'Kladno', 'A2', 'A2', 44, 0, 11, '4 + 1', '1', 2.3, 0, 'Ústřední topení', 'Vlastní v byte', 'Vlastní v byte', 'Centrálni', 'Kladno', 13200, 'Sládkovičova 4kk ', 26000, 4000, 4, '11101000', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin orci libero, sollicitudin non, lobortis vel, vehicula a, eros. Aliquam aliquam dui id magna. In tellus erat, rutrum sed, suscipit vitae, rhoncus sed, magna. Nam consectetuer ligula eget tortor. Donec massa dolor, vestibulum sed, congue at, egestas non, nibh. Etiam malesuada, ante sed gravida varius, libero elit vulputate orci, ut eges', 210, '', ''),
(6, 2, 0, 0, 'SpÃ¡lenÃ¡ 12 á', 0, 0, '', '', '', 0, 0, 0, '', '', 0, 0, '', '', '', '', 'Praha', 13200, 'Garsonka', 5000, 1500, 1, '10000010', 'Garsonka s novÃ½m kuchynskÃ½m koutem a balkonem. 6-tÃ© patro', 50, '', ''),
(7, 1, 0, 0, 'Na petřinách 52', 3, 4, '', NULL, '', NULL, 0, NULL, '4 + 1', '', NULL, NULL, '', '', '', '', 'Praha', 16200, 'Byt Petřiny', 31000, 4000, 4, '000000000000', 'Byt v tichem prostředí s výhledem do lesa.', 120, 'Petřiny', '');

-- --------------------------------------------------------

--
-- Struktura tabulky `renters`
--

CREATE TABLE `renters` (
  `id` int(8) NOT NULL auto_increment,
  `property_id` int(2) default NULL,
  `user_id` int(6) default '0',
  `name` varchar(15) NOT NULL,
  `surname` varchar(15) NOT NULL,
  `start_date` bigint(20) NOT NULL,
  `end_date` bigint(20) default '0',
  `rent_closed` tinyint(4) NOT NULL default '0',
  `email` varchar(30) NOT NULL,
  `telephone` int(11) NOT NULL,
  `address` varchar(30) NOT NULL default '?',
  `city` varchar(15) NOT NULL default '?',
  `psc` int(6) NOT NULL default '0',
  `account` int(11) default '0',
  `rent` int(6) NOT NULL default '0',
  `autopay_rent_id` int(5) default NULL,
  `note` varchar(50) character set utf8 collate utf8_czech_ci default NULL,
  `image_square` varchar(100) default NULL,
  `image_small` varchar(100) default NULL,
  `image_medium` varchar(100) default NULL,
  `image_original` varchar(100) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=21 ;

--
-- Vypisuji data pro tabulku `renters`
--

INSERT INTO `renters` (`id`, `property_id`, `user_id`, `name`, `surname`, `start_date`, `end_date`, `rent_closed`, `email`, `telephone`, `address`, `city`, `psc`, `account`, `rent`, `autopay_rent_id`, `note`, `image_square`, `image_small`, `image_medium`, `image_original`) VALUES
(1, 1, 4, 'Petr', 'Marcin', 0, 0, 0, 'marci@post.sk', 456223455, 'Italska 43', 'Praha 1', 13000, 1234597, 3000, 9, NULL, '', '', '', ''),
(2, 1, 3, 'Michal', 'Novak', 0, 0, 0, 'michali@nnk.com', 555666, '?', '?', 0, 111222444, 2700, 10, NULL, '', '', '', ''),
(3, 2, NULL, 'Martin', 'Liska', 0, 0, 0, 'MARTIN@mail.com', 1234, '?', '?', 0, 543, 3000, 11, NULL, '', '', '', ''),
(4, 3, NULL, 'Martina', 'Novakova', 0, 0, 0, 'marty@post.cz', 776983245, '?', '?', 0, 8934, 12000, 0, NULL, '', '', '', ''),
(5, 2, 6, 'Hanka', 'Vesela', 1202083200, 1233705600, 0, 'hanka@mail.com', 53258692, '?', '?', 0, 0, 5000, 23, NULL, '', '', '', ''),
(6, 3, 10, 'Marcela', 'Novotna', 1202083200, 1230768000, 0, 'marnova@gmail.com', 776249933, '?', '?', 0, 0, 11000, 12, NULL, '', '', '', ''),
(7, 5, 8, 'Lenka', 'Slana', 1204416000, 1204416000, 0, 'lesla@gmail.com', 777556445, '?', '?', 0, 0, 5400, 4, NULL, '', '', '', ''),
(8, 0, NULL, '', '', 0, 0, 0, '', 0, '?', '?', 0, 0, 0, NULL, NULL, '', '', '', ''),
(9, 6, NULL, 'Marcel', 'NovotnÃ½', 1204848000, 1236384000, 0, 'nomar@centrum.cz', 608210883, '?', '?', 0, 0, 5000, 5, NULL, '', '', '', ''),
(10, 3, NULL, 'Kryštof', 'Mlýnek', 1206921600, 1238457600, 0, 'don_krystof@gmail.com', 604300811, '?', '?', 0, 0, 15000, 6, NULL, '', '', '', ''),
(11, 5, NULL, 'Ivan', 'Bacik', 1207353600, 1238889600, 0, 'ibacik@seznam.cz', 77623879, '?', '?', 0, 0, 6000, 7, NULL, '', '', '', ''),
(12, 5, 7, 'Barbora', 'Zelena', 1207353600, 1238889600, 0, 'barca_zelena@centrum.cz', 603220796, '?', '?', 0, 0, 4500, 8, NULL, '', '', '', ''),
(0, NULL, NULL, '', '', 0, 0, 0, '', 0, '?', '?', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL),
(14, 7, 0, 'Jan', 'Ferenc', 1218412800, 1220227200, 0, 'janef@gmail.com', 2147483647, '?', '?', 0, 0, 13000, 13, NULL, NULL, NULL, NULL, NULL),
(15, 7, 0, 'Filip', 'Andrasy', 1217548800, 1220227200, 0, 'afilo@post.sk', 908342243, '?', '?', 0, 0, 11000, 14, NULL, NULL, NULL, NULL, NULL),
(16, 1, 0, 'Oliver', 'Kofler', 1220400000, 1254528000, 0, 'kofler@seznam.cz', 778345223, '?', '?', 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL),
(20, 7, 0, 'Marek', 'Maly', 1220832000, 1283904000, 0, 'mamar@centrum.sk', 778435771, '?', '?', 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Struktura tabulky `rents`
--

CREATE TABLE `rents` (
  `id` int(11) NOT NULL auto_increment,
  `renter_id` int(11) NOT NULL,
  `property_id` int(11) NOT NULL,
  `auto_pay_id` int(11) default NULL,
  `price` int(11) NOT NULL,
  `from_date` bigint(20) NOT NULL,
  `typ` enum('simple','percept') NOT NULL default 'simple',
  `note` varchar(160) character set utf8 collate utf8_czech_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=21 ;

--
-- Vypisuji data pro tabulku `rents`
--

INSERT INTO `rents` (`id`, `renter_id`, `property_id`, `auto_pay_id`, `price`, `from_date`, `typ`, `note`) VALUES
(1, 16, 0, 0, 9000, 1220462796, 'simple', NULL),
(2, 1, 0, 0, 3000, 1220540710, 'simple', NULL),
(3, 2, 0, 10, 2700, 1208714851, 'simple', NULL),
(4, 3, 0, 11, 3000, 1208869661, 'simple', NULL),
(5, 4, 0, 0, 12000, 1220540710, 'simple', NULL),
(6, 5, 0, 0, 5000, 1220540710, 'simple', NULL),
(7, 6, 0, 12, 11000, 1216910521, 'simple', NULL),
(8, 7, 0, 4, 5400, 1204484570, 'simple', NULL),
(9, 9, 0, 5, 5000, 1204885332, 'simple', NULL),
(10, 10, 0, 6, 15000, 1206991839, 'simple', NULL),
(11, 11, 0, 7, 6000, 1207347037, 'simple', NULL),
(12, 12, 0, 8, 4500, 1207347295, 'simple', NULL),
(13, 14, 0, 13, 13000, 1218455717, 'simple', NULL),
(14, 15, 0, 14, 11000, 1218532577, 'simple', NULL),
(16, 1, 0, 0, 7500, 1220745600, 'simple', 'Zmena, prilis nizky najem.'),
(20, 3, 0, 11, 7000, 1220832000, 'simple', 'Znova novy najem'),
(18, 20, 7, NULL, 5600, 1220832000, 'simple', NULL),
(19, 11, 0, 7, 7000, 1221004800, 'simple', 'test @generated_bills');

-- --------------------------------------------------------

--
-- Struktura tabulky `rooms`
--

CREATE TABLE `rooms` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(15) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

--
-- Vypisuji data pro tabulku `rooms`
--

INSERT INTO `rooms` (`id`, `name`) VALUES
(1, 'Bathroom'),
(2, 'Kitchen'),
(3, 'Room'),
(4, 'Cellar'),
(5, 'Terrace'),
(9, 'Loggia'),
(10, 'WC'),
(11, 'Hall'),
(12, 'Pantry');

-- --------------------------------------------------------

--
-- Struktura tabulky `room_areas`
--

CREATE TABLE `room_areas` (
  `id` int(11) NOT NULL auto_increment,
  `property_id` int(2) NOT NULL,
  `room_id` int(2) NOT NULL,
  `name` varchar(30) character set utf8 collate utf8_czech_ci default NULL,
  `total` float NOT NULL default '0',
  `chargable` float NOT NULL default '0',
  `UT` float NOT NULL default '0',
  `TUV` float NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=29 ;

--
-- Vypisuji data pro tabulku `room_areas`
--

INSERT INTO `room_areas` (`id`, `property_id`, `room_id`, `name`, `total`, `chargable`, `UT`, `TUV`) VALUES
(1, 7, 1, NULL, 2.87, 0.87, 2, 2.87),
(2, 7, 2, NULL, 11.38, 11.38, 11.38, 11.38),
(3, 7, 10, NULL, 1.03, 1.03, 0.21, 1.03),
(4, 7, 11, NULL, 1.69, 1.69, 0.34, 1.69),
(5, 7, 3, NULL, 20, 20, 20, 20),
(6, 7, 3, NULL, 12.01, 12.01, 12.01, 12.01),
(7, 3, 3, NULL, 15.6, 15.6, 15.6, 15.6),
(8, 1, 1, NULL, 0, 0, 0, 0),
(9, 1, 2, NULL, 0, 0, 0, 0),
(10, 1, 9, NULL, 0, 0, 0, 0),
(11, 1, 10, NULL, 0, 0, 0, 0),
(12, 1, 11, NULL, 0, 0, 0, 0),
(13, 5, 1, NULL, 0, 0, 0, 0),
(14, 5, 2, NULL, 0, 0, 0, 0),
(15, 5, 9, NULL, 0, 0, 0, 0),
(16, 5, 10, NULL, 0, 0, 0, 0),
(17, 5, 11, NULL, 0, 0, 0, 0),
(18, 5, 3, NULL, 11, 11, 11, 11),
(19, 5, 3, NULL, 11, 11, 11, 11),
(20, 2, 1, NULL, 0, 0, 0, 0),
(21, 2, 2, NULL, 0, 0, 0, 0),
(22, 2, 4, NULL, 0, 0, 0, 0),
(23, 2, 9, NULL, 0, 0, 0, 0),
(24, 2, 10, NULL, 0, 0, 0, 0),
(25, 2, 11, NULL, 0, 0, 0, 0),
(26, 2, 3, NULL, 21.44, 21.44, 21.44, 21.44),
(27, 3, 1, NULL, 10, 10, 7.2, 10),
(28, 1, 3, 'Obývak', 25.6, 25.6, 18.32, 25.6);

-- --------------------------------------------------------

--
-- Struktura tabulky `schema_info`
--

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Vypisuji data pro tabulku `schema_info`
--

INSERT INTO `schema_info` (`version`) VALUES
(18);

-- --------------------------------------------------------

--
-- Struktura tabulky `sessions`
--

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=99 ;

--
-- Vypisuji data pro tabulku `sessions`
--

INSERT INTO `sessions` (`id`, `session_id`, `data`, `updated_at`) VALUES
(74, '2f944e6d236937550bd39c799419e403', 'BAh7CDoMdXNlcl9pZGkGOhFvcmlnaW5hbF91cmkwIgpmbGFzaElDOidBY3Rp\nb25Db250cm9sbGVyOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsA\n', '2008-08-28 18:22:07'),
(75, '897755c7518a5ae8b4097204d430a047', 'BAh7CToKYmlsbHNbF2kwaQGHaQGIaQGJaQGraQGsaQGtaQGuaQGvaQHMaQHN\naQHOaQHPaQHvaQHwaQHxaQHyaQHzOgx1c2VyX2lkaQgiCmZsYXNoSUM6J0Fj\ndGlvbkNvbnRyb2xsZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA6\nEW9yaWdpbmFsX3VyaTA=\n', '2008-09-01 21:38:09'),
(76, 'ff276a7493652af5eb31bc7c28066ce8', 'BAh7CToKYmlsbHNbADoMdXNlcl9pZGkGIgpmbGFzaElDOidBY3Rpb25Db250\ncm9sbGVyOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsAOhFvcmlnaW5h\nbF91cmkw\n', '2008-08-30 18:51:02'),
(77, 'a3dfdb8aaa926551e9c6a7638aa84adb', 'BAh7CDoMdXNlcl9pZGkGIgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVyOjpG\nbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsAOhFvcmlnaW5hbF91cmkw\n', '2008-08-31 15:21:28'),
(78, '6bb8cd041a8fe77ae3d8ccdee4df9bf1', 'BAh7CzoKYmlsbHNbBmkB8ToMc29ydF9ieSINZGVhZGxpbmU6DHVzZXJfaWRp\nBjoTc29ydF9kaXJlY3Rpb246CEFTQyIKZmxhc2hJQzonQWN0aW9uQ29udHJv\nbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7ADoRb3JpZ2luYWxf\ndXJpMA==\n', '2008-09-01 19:25:14'),
(79, 'bcd0c2cde508e8d24958033d368dd297', 'BAh7CDoMdXNlcl9pZGkIIgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVyOjpG\nbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsAOhFvcmlnaW5hbF91cmkw\n', '2008-09-03 16:27:48'),
(80, '234a032fed699396f21dd358f062393f', 'BAh7CDoMdXNlcl9pZGkGIgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVyOjpG\nbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsAOhFvcmlnaW5hbF91cmkw\n', '2008-09-02 20:19:48'),
(81, 'f2a24d20358fd78511a9b1dcca22de83', 'BAh7EDoacmVhbF9pbmNvbWVfYmlsbHNfaWRzWwA6G3JlYWxfb3V0Y29tZV9i\naWxsc19pZHNbADofZXhwZWN0ZWRfb3V0Y29tZV9iaWxsc19pZHNbADoMc29y\ndF9ieSINZGVhZGxpbmU6DHVzZXJfaWRpBjoTZ3JhcGhfc2V0dGluZ3N7BzoK\nbW9udGhpDjoJeWVhcmkC2Ac6HmV4cGVjdGVkX2luY29tZV9iaWxsc19pZHNb\nPmkCNwFpAlABaQJuAWkCUQFpAkQBaQJSAWkCNgFpAlMBaQJHAWkCVAFpAksB\naQJVAWkCPAFpAkABaQJWAWkCTwFpAlcBaQI4AWkCWAFpAlkBaQJIAWkCWgFp\nAlsBaQJMAWkCPQFpAlwBaQJBAWkCXQFpAl4BaQI5AWkCXwFpAkUBaQJgAWkC\nYQFpAkkBaQJiAWkCTQFpAmMBaQJCAWkCPgFpAmQBaQJlAWkCOgFpAmYBaQJn\nAWkCaAFpAkoBaQJpAWkCTgFpAmoBaQI/AWkCQwFpAmsBaQI7AWkCbAFpAkYB\naQJtAToTc29ydF9kaXJlY3Rpb246CEFTQzoKYmlsbHNbFmkB0GkB0WkB0mkB\n02kB9GkB9WkB9mkB92kCGAFpAhkBaSxpAhsBaQIcAWkCSwFpAkwBaQJNAWkC\nTgE6EW9yaWdpbmFsX3VyaTAiCmZsYXNoSUM6J0FjdGlvbkNvbnRyb2xsZXI6\nOkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA=\n', '2008-09-02 22:10:48'),
(82, 'a0a817ea36d44fa67b125729db52c75d', 'BAh7CDoMdXNlcl9pZGkGOhFvcmlnaW5hbF91cmkwIgpmbGFzaElDOidBY3Rp\nb25Db250cm9sbGVyOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsA\n', '2008-09-03 19:28:12'),
(83, '1145308f0c3b34900a6e033259ff1502', 'BAh7EDoacmVhbF9pbmNvbWVfYmlsbHNfaWRzWw9pAhYBaQIpAWkCGwFpAgsB\naQIqAWkCEAFpAisBaQIsAWkCBwFpAi0BOhtyZWFsX291dGNvbWVfYmlsbHNf\naWRzWwZpAgIBOh9leHBlY3RlZF9vdXRjb21lX2JpbGxzX2lkc1sAOgpiaWxs\nc1sLaQHdaQHeaQHfaQH/aQIAAWkCAQE6DHNvcnRfYnkiDWRlYWRsaW5lOh5l\neHBlY3RlZF9pbmNvbWVfYmlsbHNfaWRzWz5pAjcBaQJQAWkCbgFpAlEBaQJE\nAWkCUgFpAjYBaQJTAWkCRwFpAlQBaQJLAWkCVQFpAjwBaQJAAWkCVgFpAk8B\naQJXAWkCOAFpAlgBaQJZAWkCSAFpAloBaQJbAWkCTAFpAj0BaQJcAWkCQQFp\nAl0BaQJeAWkCOQFpAl8BaQJFAWkCYAFpAmEBaQJJAWkCYgFpAk0BaQJjAWkC\nQgFpAj4BaQJkAWkCZQFpAjoBaQJmAWkCZwFpAmgBaQJKAWkCaQFpAk4BaQJq\nAWkCPwFpAkMBaQJrAWkCOwFpAmwBaQJGAWkCbQE6E2dyYXBoX3NldHRpbmdz\newg6CmxpbmVzIg1leHBlY3RlZDoKbW9udGhpDjoJeWVhcmkC2Ac6DHVzZXJf\naWRpBjoTc29ydF9kaXJlY3Rpb246CEFTQyIKZmxhc2hJQzonQWN0aW9uQ29u\ndHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7ADoRb3JpZ2lu\nYWxfdXJpMA==\n', '2008-09-04 19:51:08'),
(84, 'b916eda9026f03daa2dc62ed681deae6', 'BAh7CDoMdXNlcl9pZGkIOhFvcmlnaW5hbF91cmkwIgpmbGFzaElDOidBY3Rp\nb25Db250cm9sbGVyOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsA\n', '2008-09-04 16:15:57'),
(85, 'fad6213667811e902e82f55be6936410', 'BAh7EDoacmVhbF9pbmNvbWVfYmlsbHNfaWRzWxhpAh8BaQIgAWkCIQFpAiIB\naQIaAWkCIwFpAiQBaQIlAWkCbwFpAiYBaQInAWkCKAFpAi4BaQIvAWkCMAFp\nAjEBaQI0AWkCMgFpAjMBOgpiaWxsc1sfaQJUAWkCVQFpAlYBaQJXAWkCWAFp\nAlkBaQJaAWkCWwFpAlwBaQJdAWkCXgFpAl8BaQJgAWkCYQFpAmIBaQJjAWkC\nZAFpAmUBaQJmAWkCZwFpAmgBaQJpAWkCagFpAmsBaQJsAWkCbQE6DHNvcnRf\nYnkiDWRlYWRsaW5lOhtyZWFsX291dGNvbWVfYmlsbHNfaWRzWwA6DHVzZXJf\naWRpBjofZXhwZWN0ZWRfb3V0Y29tZV9iaWxsc19pZHNbADoTc29ydF9kaXJl\nY3Rpb246CEFTQyIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6\nOkZsYXNoSGFzaHsABjoKQHVzZWR7ADoRb3JpZ2luYWxfdXJpMDoeZXhwZWN0\nZWRfaW5jb21lX2JpbGxzX2lkc1s7aQIeAWkCGAFpAggBaQINAWkCAwFpAgQB\naQISAWkCFAFpAh0BaQIZAWkCCQFpAg4BaQIFAWkCHwFpAiABaQIhAWkCFQFp\nAiIBaQIaAWkCIwFpAg8BaQIKAWkCJAFpV2k0aQIlAWkCBgFpAm8BaQImAWkC\nEwFpAicBaQIoAWkCFgFpLGkCKQFpAhsBaQILAWkCKgFpAhABaQIrAWkCLAFp\nAgcBaQItAWkCLgFpAhcBaQIvAWkCMAFpAhwBaQIMAWkCMQFpAhEBaQI0AWkC\nMgFpAjMBOhNncmFwaF9zZXR0aW5nc3sIOgpsaW5lcyINZXhwZWN0ZWQ6Cm1v\nbnRoaQ06CXllYXJpAtgH\n', '2008-09-05 15:58:41'),
(86, 'f99bc461e2896f8838ce0bb6cfb8ff5c', 'BAh7CDoMdXNlcl9pZGkGOhFvcmlnaW5hbF91cmkwIgpmbGFzaElDOidBY3Rp\nb25Db250cm9sbGVyOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsA\n', '2008-09-05 17:25:29'),
(87, '1b656adf6da5f8219a35795b26b5db01', 'BAh7CDoMdXNlcl9pZGkIOhFvcmlnaW5hbF91cmkwIgpmbGFzaElDOidBY3Rp\nb25Db250cm9sbGVyOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsA\n', '2008-09-05 16:14:25'),
(88, '5ead3b88b31e72e8bdfdcf7db986666b', 'BAh7CDoMdXNlcl9pZGkGOhFvcmlnaW5hbF91cmkwIgpmbGFzaElDOidBY3Rp\nb25Db250cm9sbGVyOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsA\n', '2008-09-05 19:45:22'),
(89, '946cbb30fb8e8cec0ca859272ddf3c13', 'BAh7CDoMdXNlcl9pZGkGIgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVyOjpG\nbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsAOhFvcmlnaW5hbF91cmkw\n', '2008-09-06 11:57:40'),
(90, '62929407db1f942b5b4b3ee57c953001', 'BAh7CDoMdXNlcl9pZGkGIgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVyOjpG\nbGFzaDo6Rmxhc2hIYXNoewY6C25vdGljZSIlUHJpIHZ5dHbDocWZZW7DrSBk\nb8WhbG8gayBjaHlixJsGOgpAdXNlZHsGOwdUOhFvcmlnaW5hbF91cmkw\n', '2008-09-06 20:21:20'),
(91, '4feb8f145c823d5555996e538759e381', 'BAh7DDoTZ3JhcGhfc2V0dGluZ3N7BzoKbW9udGhpDjoJeWVhcmkC2Ac6CmJp\nbGxzWwdpAh4BaQJuAToMc29ydF9ieSINZGVhZGxpbmU6DHVzZXJfaWRpBjoT\nc29ydF9kaXJlY3Rpb246CEFTQzoRb3JpZ2luYWxfdXJpMCIKZmxhc2hJQzon\nQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7\nAA==\n', '2008-09-07 16:10:34'),
(92, '20e6ba50158e28d9b5f44ef18bae5eb3', 'BAh7CzoMc29ydF9ieSINZGVhZGxpbmU6CmJpbGxzWxVpAdBpAdFpAdJpAdNp\nAfRpAfVpAfZpAfdpAhgBaQIZAWksaQIcAWkCSwFpAkwBaQJNAWkCTgE6DHVz\nZXJfaWRpBjoTc29ydF9kaXJlY3Rpb246CEFTQzoRb3JpZ2luYWxfdXJpMCIK\nZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsA\nBjoKQHVzZWR7AA==\n', '2008-09-08 20:20:24'),
(93, '5c0b60859dfa1bd1d73a233e27df428a', 'BAh7EDoTZ3JhcGhfc2V0dGluZ3N7BzoKbW9udGhpDjoJeWVhcmkC2Ac6HmV4\ncGVjdGVkX2luY29tZV9iaWxsc19pZHNbQGkCbgFpAjcBaQJQAWkCUQFpAkQB\naQJSAWkCNgFpAlMBaQJHAWkCVAFpAksBaQJAAWkCPAFpAlUBaQJWAWkCTwFp\nAjgBaQJXAWkCWAFpAlkBaQJIAWkCWgFpAlsBaQJMAWkCXAFpAj0BaQJBAWkC\nXQFpAjkBaQJeAWkCXwFpAkUBaQJwAWkCYAFpAkkBaQJhAWkCYgFpAk0BaQJC\nAWkCYwFpAj4BaQJkAWkCOgFpAmUBaQJmAWkCZwFpAnEBaQJoAWkCSgFpAmkB\naQJOAWkCPwFpAkMBaQJqAWkCawFpAmwBaQI7AWkCRgFpAm0BOhpyZWFsX2lu\nY29tZV9iaWxsc19pZHNbE2kCFgFpAikBaQIbAWkCCwFpAhABaQIqAWkCKwFp\nAgcBaQIsAWkCLQFpAlABaQJRAWkCUgFpAlMBOgxzb3J0X2J5Ig1kZWFkbGlu\nZToKYmlsbHNbD2kB9mkB92kCGAFpAhkBaSxpAhwBaQJLAWkCTAFpAk0BaQJO\nAToMdXNlcl9pZGkGOhNzb3J0X2RpcmVjdGlvbjoIQVNDOhFvcmlnaW5hbF91\ncmkwIgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVyOjpGbGFzaDo6Rmxhc2hI\nYXNoewAGOgpAdXNlZHsAOhtyZWFsX291dGNvbWVfYmlsbHNfaWRzWwZpAgIB\nOh9leHBlY3RlZF9vdXRjb21lX2JpbGxzX2lkc1sA\n', '2008-09-09 22:24:49'),
(94, '0342a061e0cf5becdbee4cf77f0b0e1e', 'BAh7CzoKYmlsbHNbe2kB+WkB+mkB1WkB2GkBvWkBvGkB+2kBvmkB1mkBv2kB\ntWkBwGkBtmkBt2kBwWkB4GkB4WkB/GkB5mkB4mkB3WkB9mkB62kB52kB42kB\n3mkB92kB7GkB6GkB5GkB2WkB32kB2mkCHgFpAhgBaQINAWkCCAFpAgMBaQIE\nAWkB/2kCEgFpAhQBaQIdAWkCGQFpAgkBaQIOAWkCBQFpAgABaQIVAWkCCgFp\nAg8BaQIGAWkCAQFpAhMBaSxpAhcBaQH9aQIcAWkCEQFpAgwBaQH+aQJuAWkC\nNwFpAkQBaQI2AWkCRwFpAlQBaQJLAWkCQAFpAjwBaQJVAWkCVgFpAk8BaQJX\nAWkCOAFpAlgBaQJZAWkCSAFpAloBaQJbAWkCTAFpAkEBaQI9AWkCXAFpAl0B\naQJeAWkCOQFpAl8BaQJFAWkCYAFpAnABaQJJAWkCYQFpAmIBaQJNAWkCYwFp\nAkIBaQI+AWkCZAFpAmUBaQI6AWkCZgFpAmcBaQJxAWkCaAFpAkoBaQJpAWkC\nTgFpAkMBaQI/AWkCagFpAmsBaQI1AWkCbAFpAjsBaQJtAWkCRgFpLjoMc29y\ndF9ieSINZGVhZGxpbmU6DHVzZXJfaWRpBjoTc29ydF9kaXJlY3Rpb246CEFT\nQyIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFz\naHsABjoKQHVzZWR7ADoRb3JpZ2luYWxfdXJpMA==\n', '2008-09-11 21:55:56'),
(95, '1c1de6e7db3ccd8594d04f98b8cbf271', 'BAh7CzoMc29ydF9ieSINZGVhZGxpbmU6CmJpbGxzWwlpAnQBaQJ1AWkCdgFp\nAncBOgx1c2VyX2lkaQY6E3NvcnRfZGlyZWN0aW9uOghBU0MiCmZsYXNoSUM6\nJ0FjdGlvbkNvbnRyb2xsZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2Vk\newA6EW9yaWdpbmFsX3VyaTA=\n', '2008-09-12 17:46:39'),
(96, 'b59924e89a65191cf1e389bf68310122', 'BAh7CzoRb3JpZ2luYWxfdXJpMDoKYmlsbHNbFGkCVwFpAjgBaQJYAWkCWQFp\nAkgBaQJaAWkCWwFpAnYBaQJMAWkCQQFpAlwBaQI9AWkCXQFpAjkBaQJeAToM\nc29ydF9ieSINZGVhZGxpbmUiCmZsYXNoSUM6J0FjdGlvbkNvbnRyb2xsZXI6\nOkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA6DHVzZXJfaWRpBjoTc29y\ndF9kaXJlY3Rpb246CEFTQw==\n', '2008-09-14 14:34:38'),
(97, '5418b1cd89563ba22f0dd21ec697b1f3', 'BAh7CzoRb3JpZ2luYWxfdXJpMDoMc29ydF9ieTA6CmJpbGxzWxRpAg4BaQIF\nAWkCAAFpAhUBaQJ0AWkCDwFpAgoBaQIGAWkCAQFpAhMBaSxpAhcBaQH9aQJ1\nAWkCHAEiCmZsYXNoSUM6J0FjdGlvbkNvbnRyb2xsZXI6OkZsYXNoOjpGbGFz\naEhhc2h7AAY6CkB1c2VkewA6DHVzZXJfaWRpBjoTc29ydF9kaXJlY3Rpb24w\n', '2008-09-14 22:17:08'),
(98, '9b5715cdc17ab1990900b64f130a326b', 'BAh7DToRb3JpZ2luYWxfdXJpMDoKYmlsbHNbFGkB7GkB5GkB2WkB32kB2mkC\nHgFpAhgBaQINAWkCCAFpAgMBaQIEAWkB/2kCEgFpAhQBaQIZAToMc29ydF9i\neTA6DW9yZGVyX2J5Ig1kZWFkbGluZSIKZmxhc2hJQzonQWN0aW9uQ29udHJv\nbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7ADoMdXNlcl9pZGkG\nOhRvcmRlcl9kaXJlY3Rpb246CEFTQzoTc29ydF9kaXJlY3Rpb24w\n', '2008-09-15 18:08:36');

-- --------------------------------------------------------

--
-- Struktura tabulky `temp_bills`
--

CREATE TABLE `temp_bills` (
  `id` int(11) NOT NULL auto_increment,
  `bill_id` int(11) NOT NULL,
  `price` int(11) NOT NULL default '0',
  `penalty` int(11) default '0',
  `paid` bigint(13) default '0',
  `note` varchar(160) default NULL,
  `send_info` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=14 ;

--
-- Vypisuji data pro tabulku `temp_bills`
--

INSERT INTO `temp_bills` (`id`, `bill_id`, `price`, `penalty`, `paid`, `note`, `send_info`) VALUES
(1, 242, 2700, 0, 1216857600, NULL, 0),
(2, 243, 2000, 0, 1217203200, NULL, 0),
(3, 243, 700, 0, 1217462400, NULL, 0),
(4, 204, 2700, 0, 1217462400, NULL, 0),
(5, 205, 2700, 0, 1217462400, NULL, 0),
(6, 206, 2700, 0, 1217462400, NULL, 0),
(7, 239, 2700, 0, 1217548800, 'Dohodnuty deadline 10.7.08', 0),
(8, 241, 2300, 0, 1217548800, '', 0),
(9, 241, 100, 0, 1216252800, '', 0),
(10, 207, 2700, 0, 1214438400, '', 0),
(11, 240, 2700, 0, 1215648000, '', 0),
(12, 248, 11000, 0, 1204761600, 'PRva platba z rozhrania pre najomnikov', 0),
(13, 307, 100, 0, 1220140800, 'Informace su cenne, je to proste tak. Dakujem za spravu.', 0);

-- --------------------------------------------------------

--
-- Struktura tabulky `todos`
--

CREATE TABLE `todos` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `added` int(11) NOT NULL,
  `fulfiled` tinyint(1) default '0',
  `show_to_renter` tinyint(1) NOT NULL default '1',
  `property_id` int(5) NOT NULL default '0',
  `task` varchar(25) NOT NULL,
  `description` varchar(256) NOT NULL,
  `actor` varchar(25) NOT NULL,
  `deadline` bigint(13) NOT NULL,
  `cost` int(11) default '0',
  `notif` bigint(13) NOT NULL default '0',
  `priority` enum('high','medium','low') NOT NULL default 'low',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=64 ;

--
-- Vypisuji data pro tabulku `todos`
--

INSERT INTO `todos` (`id`, `user_id`, `added`, `fulfiled`, `show_to_renter`, `property_id`, `task`, `description`, `actor`, `deadline`, `cost`, `notif`, `priority`) VALUES
(44, 1, 1202259479, 0, 1, 0, 'Poznamka', 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor i', 'r', 0, NULL, 1, 'low'),
(45, 1, 1212825524, 0, 1, 0, 'Pridat kategorie', 'Rychlo', 'Michal', 1212796800, NULL, 1, 'low'),
(46, 1, 1202486028, 0, 1, 0, 'zmena formulare', '', 'ror', 0, NULL, 0, 'low'),
(47, 1, 1202487668, 0, 1, 0, 'back', '', 'a', 0, NULL, 0, 'low'),
(48, 1, 1202489060, 0, 1, 0, 'params', '', 'w', 0, NULL, 0, 'low'),
(49, 1, 1215256917, 0, 1, 0, 'redirect', 'Testovanie presmerovanie', 'e', 1215216000, NULL, 0, 'low'),
(50, 1, 1202489339, 0, 1, 0, 'todo', '', 'r', 0, NULL, 0, 'low'),
(51, 1, 1202756263, 0, 1, 5, 'Koupit koberec', '', 'majitel', 0, NULL, 1203465600, ''),
(52, 1, 1208979788, 0, 1, 5, 'Novy task manager', 'Zmenit inreface na zadavanie ukolov do ukolovnika', '', 0, NULL, 0, ''),
(55, 1, 1209026997, 0, 1, 5, 'Deadline datum', 'Zmena deadline z textu na datum', '', 1209945600, NULL, 0, 'low'),
(56, 1, 1212826136, 0, 1, 0, 'Novy ukol', 'Testovanie pridania do databazy', '', 1213920000, NULL, 0, 'low'),
(57, 1, 1211274209, 0, 1, 0, 'Novy ukol 2', 'Testovanie pridania do databazy 2', '', 1211241600, NULL, 0, 'low'),
(58, 1, 1211916227, 0, 1, 1, 'Vymalovat pokoje', 'Obyvak, loznice, balkon. Balkon je pÅ™edsazenÃ¡ konstrukce, pÅ™eÄnÃ­vajÃ­cÃ­ pÅ™es nosnou zeÄ. Balkon mÅ¯Å¾e bÃ½t polozapuÅ¡tÄ›nÃ½ do nosnÃ½ch zdÃ­, konstrukÄnÄ› pÅ™edstavujÃ­cÃ­ kombinaci balkonovÃ© konzoly a lodÅ¾ie.', '', 1211846400, NULL, 0, 'low'),
(59, 1, 1212784099, 0, 1, 0, 'Novy ukol2', 'testovaci2', '', 1212710400, NULL, 0, 'low'),
(60, 1, 1212826089, 0, 1, 3, 'Zprovoznit bazen', 'Vypustit vodu, umyt bazen + plochu kolem bazenu. Skontrolovat kryt bazenu, ci nie je poskodeny.', '', 1213920000, NULL, 1, 'medium'),
(61, 1, 1215256860, 0, 1, 2, 'Pridat kontakty', 'Kontakty na udrzbu nemovitosti.', '', 1215216000, NULL, 0, 'low'),
(62, 1, 1216743618, 0, 1, 7, 'Najemnici', 'Nastehovat minimalne 3 najemnikov do konce cervence.', '', 1217462400, NULL, 1217289600, 'medium'),
(63, 1, 1220112672, 0, 0, 1, 'Nezobrazit najemnikum', 'Tento ukol sa nesmie zobrazir najomnikom. Ukol sluzi ako interny, iba pre prenajimatela, pre najomnikov je bezpredmetny.', '', 1220054400, NULL, 0, 'low');

-- --------------------------------------------------------

--
-- Struktura tabulky `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(15) collate utf8_czech_ci NOT NULL,
  `hashed_password` varchar(50) collate utf8_czech_ci NOT NULL,
  `salt` varchar(30) collate utf8_czech_ci NOT NULL,
  `last_login` bigint(13) NOT NULL,
  `renter_id` int(6) default '0',
  `typ` enum('renter','admin') collate utf8_czech_ci NOT NULL default 'renter',
  `admin_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci AUTO_INCREMENT=11 ;

--
-- Vypisuji data pro tabulku `users`
--

INSERT INTO `users` (`id`, `name`, `hashed_password`, `salt`, `last_login`, `renter_id`, `typ`, `admin_id`) VALUES
(1, 'michal', '446cd011171c4b6814249325397e1dfb06af8648', '434706400.434480009082405', 1221488029, 0, 'admin', 1),
(2, 'tester', 'e210a7e1c0f304f068e0d439d1f7b3f25b83bca2', '501814100.712845401796762', 0, 0, 'admin', 0),
(3, 'renter', '70a26ebc3dc1f62ab3a5d91e820a083ecee0bde9', '550267100.851747931194804', 1220624047, 2, 'renter', 1),
(4, 'petr.marcin', 'bb2774ebd5302ddc321037db950da3838d8aab73', '549233400.660924428203435', 1219675489, 1, 'renter', 1),
(6, 'vesela.hanka', 'ef7ade7ee2c999ec502f3718fe7f213ed753361d', '429777500.813267314862086', 1219580053, 5, 'renter', 1),
(7, 'barbora.zelena', '490153f4b1696587732b64d8a06ca0406995d39f', '719475200.902673577475014', 0, 12, 'renter', 1),
(8, 'lenka.slana', '8c4b75d64e084ea1566121108bcda6913cbaf498', '555284900.815679775868548', 0, 7, 'renter', 1),
(9, 'jozef', 'e59c8604c7d9fe5f642ca9c1ecc652997c0f2871', '556409400.902309550658498', 1219579998, 0, 'admin', 0),
(10, 'marcela.novotna', 'f2ea14ce4f8f7a3786e20b9155d73ba87ef80b93', '771494100.666209799493719', 1219580169, 6, 'renter', 1);