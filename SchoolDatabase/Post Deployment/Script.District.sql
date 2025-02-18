﻿/*
Post-Deployment Script Template              
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.    
 Use SQLCMD syntax to include a file in the post-deployment script.      
 Example:      :r .\myfile.sql                
 Use SQLCMD syntax to reference a variable in the post-deployment script.    
 Example:      :setvar TableName MyTable              
               SELECT * FROM [$(TableName)]          
--------------------------------------------------------------------------------------
*/
DECLARE @District TABLE(
  DistrictId INT, 
  StateId INT, 
  DistrictName NVARCHAR(100), 
  DistrictKey NVARCHAR(100)
);
INSERT INTO @District(
  DistrictId, StateId, DistrictName, 
  DistrictKey
) 
VALUES 
  (1, 1, 'Pune', 'Pune'), 
  (2, 1, 'Ahmednagar', 'Ahmednagar'), 
  (3, 1, 'Akola', 'Akola'), 
  (4, 1, 'Amravati', 'Amravati'), 
  (5, 1, 'Aurangabad', 'Aurangabad'), 
  (6, 1, 'Beed', 'Beed'), 
  (7, 1, 'Bhandara', 'Bhandara'), 
  (8, 1, 'Buldhana', 'Buldhana'), 
  (9, 1, 'Chandrapur', 'Chandrapur'), 
  (10, 1, 'Dhule', 'Dhule'), 
  (11, 1, 'Gadchiroli', 'Gadchiroli'), 
  (12, 1, 'Gondia', 'Gondia'), 
  (13, 1, 'Hingoli', 'Hingoli'), 
  (14, 1, 'Jalgaon', 'Jalgaon'), 
  (15, 1, 'Jalna', 'Jalna'), 
  (16, 1, 'Kolhapur', 'Kolhapur'), 
  (17, 1, 'Latur', 'Latur'), 
  (18, 1, 'Mumbai City', 'Mumbai_City'), 
  (19, 1, 'Mumbai Suburban', 'Mumbai_Suburban'), 
  (20, 1, 'Nagpur', 'Nagpur'), 
  (21, 1, 'Nanded', 'Nanded'), 
  (22, 1, 'Nandurbar', 'Nandurbar'), 
  (23, 1, 'Nashik', 'Nashik'), 
  (24, 1, 'Osmanabad', 'Osmanabad'), 
  (25, 1, 'Palghar', 'Palghar'), 
  (26, 1, 'Parbhani', 'Parbhani'), 
  (27, 1, 'Raigad', 'Raigad'), 
  (28, 1, 'Ratnagiri', 'Ratnagiri'), 
  (29, 1, 'Sangli', 'Sangli'), 
  (30, 1, 'Satara', 'Satara'), 
  (31, 1, 'Sindhudurg', 'Sindhudurg'), 
  (32, 1, 'Solapur', 'Solapur'), 
  (33, 1, 'Thane', 'Thane'), 
  (34, 1, 'Wardha', 'Wardha'), 
  (35, 1, 'Washim', 'Washim'), 
  (36, 1, 'Yavatmal', 'Yavatmal'),
  (37, 2, 'Bagalkote', 'Bagalkote'), 
(38, 2, 'Ballari', 'Ballari'), 
(39, 2, 'Belagavi', 'Belagavi'), 
(
  40, 2, N'Bengaluru Urban', 'Bengaluru_Urban'
), 
(
  41, 2, N'Bengaluru Rural', 'Bengaluru_Rural'
), 
(42, 2, 'Bidar', 'Bidar'), 
(
  43, 2, 'Chamarajanagara', 'Chamarajanagara'
), 
(
  44, 2, 'Chikkaballapura', 'Chikkaballapura'
), 
(
  45, 2, 'Chikkmagaluru', 'Chikkmagaluru'
), 
(
  46, 2, 'Chitradurga', 'Chitradurga'
), 
(
  47, 2, N'Dakshina Kannada', 'Dakshina_Kannada'
), 
(48, 2, 'Davanagere', 'Davanagere'), 
(49, 2, 'Dharwad', 'Dharwad'), 
(50, 2, 'Gadag', 'Gadag'), 
(51, 2, 'Hassan', 'Hassan'), 
(52, 2, 'Haveri', 'Haveri'), 
(53, 2, 'Kalaburagi', 'Kalaburagi'), 
(54, 2, 'Kodagu', 'Kodagu'), 
(55, 2, 'Kolar', 'Kolar'), 
(56, 2, 'Koppala', 'Koppala'), 
(57, 2, 'Mandya', 'Mandya'), 
(58, 2, 'Mysuru', 'Mysuru'), 
(59, 2, 'Raichuru', 'Raichuru'), 
(60, 2, 'Ramanagara', 'Ramanagara'), 
(61, 2, 'Shivamogga', 'Shivamogga'), 
(62, 2, 'Tumakuru', 'Tumakuru'), 
(63, 2, 'Udupi', 'Udupi'), 
(
  64, 2, N'Uttara Kannada', 'Uttara_Kannada'
), 
(
  65, 2, 'Vijayapura','Vijayapura'),
(66,2,' Yadagiri', 'Yadagiri'), 
(
  67, 2, 'Vijayanagara', 'Vijayanagara'
),
(68,3,N'Alluri Sitharama Raju','Alluri_Sitharama_Raju'),  (69,3,'Anakapalli','Anakapalli'),  
(70,3,'Anantapur','Anantapur'),  (71,3,'Annamayya','Annamayya'),  (72,3,'Bapatla','Bapatla'), 
(73,3,'Chittoor','Chittoor'),  (74,3,N'East Godavari','East_Godavari'),  (75,3,'Eluru','Eluru'), 
(76,3,'Guntur','Guntur'), (77,3,'Kakinada','Kakinada'),  (78,3,'Konaseema','Konaseema'), 
(79,3,'Krishna','Kakinada'), (80,3,'Kurnool','Kurnool'), (81,3,'NTR','NTR'), (82,3,'Nandyal','Nandyal'),
(83,3,'Palnadu','Palnadu'), (84,3,N'Parvathipuram Manyam','Parvathipuram_Manyam'), (85,3,'Prakasam','Prakasam'), 
(86,3,N'Spsr Nellore','Spsr_Nellore'), (87,3,N'Sri Sathya Sai','Sri_Sathya_Sai'), (88,3,'Srikakulam','Srikakulam'),
(89,3,'Tirupati','Tirupati'), (90,3,'Visakhapatanam','Visakhapatanam'), (91,3,'Vizianagaram','Vizianagaram'), 
(92,3,N'West Godavari','West_Godavari'), (93,3,'YSR','YSR'),
(94,4,'Anjaw','Anjaw'), (95,4,'Changlang','Changlang'), (96,4,N'Dibang Valley','Dibang_Valley'), 
(97,4,N'East Kameng','East_Kameng'), (98,4,N'East Siang','East_Siang'), (99,4,'Kamle','Kamle'), 
(100,4,N'Kra Daadi','Kra_Daadi'), (101,4,N'Kurung Kumey','Kurung_Kumey'), (102,4,'Leparada','Leparada'), 
(103,4,'Lohit','Lohit'), (104,4,'Longding','Longding'), (105,4,N'Lower Dibang Valley','Lower_Dibang_Valley'), 
(106,4,N'Lower Siang','Lower_Siang'), (107,4,N'Lower Subansiri','Lower_Subansiri'), (108,4,'Namsai','Namsai'), 
(109,4,N'Pakke Kessang','Pakke_Kessang'), (110,4,N'Papum Pare','Papum_Pare'), (111,4,N'Shi Yomi','Shi_Yomi'),
(112,4,'Siang','Siang'), (113,4,'Tawang','Tawang'), (114,4,'Tirap','Tirap'), (115,4,N'Upper Siang','Upper_Siang'), 
(116,4,N'Upper Subansiri','Upper_Subansiri'), (117,4,N'West Kameng','West_Kameng'), (118,4,N'West Siang','West_Siang'),
(119,5,'Bajali','Bajali'),
(120,5,'Baksa','Baksa'),
(121,5,'Barpeta','Barpeta'),
(122,5,'Biswanath','Biswanath'),
(123,5,'Bongaigaon','Bongaigaon'),
(124,5,'Cachar','Cachar'),
(125,5,'Charaideo','Charaideo'),
(126,5,'Chirang','Chirang'),
(127,5,'Darrang','Darrang'),
(128,5,'Dhemaji','Dhemaji'),
(129,5,'Dhubri','Dhubri'),
(130,5,'Dibrugarh','Dibrugarh'),
(131,5,'Dima Hasao','Dima_Hasao'),
(132,5,'Goalpara','Goalpara'),
(133,5,'Golaghat','Golaghat'),
(134,5,'Hailakandi','Hailakandi'),
(135,5,'Hojai','Hojai'),
(136,5,'Jorhat','Jorhat'),
(137,5,'Kamrup','Kamrup'),
(138,5,'Kamrup Metro','Kamrup_Metro'),
(139,5,'Karbi Anglong','Karbi_Anglong'),
(140,5,'Karimganj','Karimganj'),
(141,5,'Kokrajhar','Kokrajhar'),
(142,5,'Lakhimpur','Lakhimpur'),
(143,5,'Majuli','Majuli'),
(144,5,'Marigaon','Marigaon'),
(145,5,'Nagaon','Nagaon'),
(146,5,'Nalbari','Nalbari'),
(147,5,'Sivasagar','Sivasagar'),
(148,5,'Sonitpur','Sonitpur'),
(149,5,N'South Salmara-Mankachar','South_Salmara_Mankachar'),
(150,5,'Tamulpur','Tamulpur'),
(151,5,'Tinsukia','Tinsukia'),
(152,5,'Udalguri','Udalguri'),
(153,5,'West Karbi Anglong','West_Karbi_Anglong'),
(154,6,'Araria ','Araria '),
(155,6,'Arwal','Arwal'),
(156,6,N'Aurangabad(BH)','Aurangabad_BH'),
(157,6,'Banka','Banka'),
(158,6,'Begusarai','Begusarai'),
(159,6,'Bhagalpur','Bhagalpur'),
(160,6,'Bhojpur','Bhojpur'),
(161,6,'Buxar','Buxar'),
(162,6,'Darbhanga','Darbhanga'),
(163,6,'Gaya','Gaya'),
(164,6,'Gopalganj','Gopalganj'),
(165,6,'Jamui','Jamui'),
(166,6,'Jehanabad','Jehanabad'),
(167,6,N'Kaimur(Bhabua)','Kaimur_Bhabua'),
(168,6,'Katihar','Katihar'),
(169,6,'Khagaria','Khagaria'),
(170,6,'Kishanganj','Kishanganj'),
(171,6,'Lakhisarai','Lakhisarai'),
(172,6,'Madhepura','Madhepura'),
(173,6,'Madhubani','Madhubani'),
(174,6,'Munger','Munger'),
(175,6,'Muzaffarpur','Muzaffarpur'),
(176,6,'Nalanda','Nalanda'),
(177,6,'Nawada','Nawada'),
(178,6,'Pashchim Champaran','Pashchim_Champaran'),
(179,6,'Samastipur','Samastipur'),
(180,6,'Saran','Saran'),
(181,6,'Sheikhpura','Sheikhpura'),
(182,6,'Sheohar','Sheohar'),
(183,6,'Sitamarhi','Sitamarhi'),
(184,6,'Patna','Patna'),
(185,6,'Purbi Champaran','Purbi_Champaran'),
(186,6,'Purnia','Purnia'),
(187,6,'Rohtas','Rohtas'),
(188,6,'Saharsa','Saharsa'),
(189,6,'Siwan','Siwan'),
(190,6,'Supaul','Supaul'),
(191,6,'Vaishali','Vaishali'),
(192,7,'Balod','Balod'),
(193,7,'Baloda Bazar','Baloda_Bazar'),
(194,7,'Balrampur','Balrampur'),
(195,7,'Bastar','Bastar'),
(196,7,'Bemetara','Bemetara'),
(197,7,'Bijapur','Bijapur'),
(198,7,'Bilaspur','Bilaspur'),
(199,7,'Dantewada','Dantewada'),
(200,7,'Dhamtari','Dhamtari'),
(201,7,'Durg','Durg'),
(202,7,'Gariyaband','Gariyaband'),
(203,7,'Gaurella Pendra Marwahi','Gaurella_Pendra_Marwahi'),
(204,7,N'Janjgir-Champa','Janjgir_Champa'),
(205,7,'Jashpur','Jashpur'),
(206,7,'Kabirdham','Kabirdham'),
(207,7,'Kanker','Kanker'),
(208,7,'Khairagarh Chhuikhadan Gandai','Khairagarh_Chhuikhadan_Gandai'),
(209,7,'Kondagaon','Kondagaon'),
(210,7,'Korba','Korba'),
(211,7,'Korea','Korea'),
(212,7,'Mahasamund','Mahasamund'),
(213,7,'Manendragarh Chirmiri Bharatpur','Manendragarh_Chirmiri_Bharatpur'),
(214,7,'Mohla Manpur Ambagarh Chouki','Mohla_Manpur_Ambagarh_Chouki'),
(215,7,'Mungeli','Mungeli'),
(216,7,'Narayanpur','Narayanpur'),
(217,7,'Raigarh','Raigarh'),
(218,7,'Raipur','Raipur'),
(219,7,'Rajnandgaon','Rajnandgaon'),
(220,7,'Sakti','Sakti'),
(221,7,'Sarangarh Bilaigarh','Sarangarh_Bilaigarh'),
(222,7,'Sukma','Sukma'),
(223,7,'Surajpur','Surajpur'),
(224,7,'Surguja','Surguja'),
(225,8,'North Goa','North_Goa'),
(226,8,'South Goa','South_Goa'),
(227,9,'Ahmedabad','Ahmedabad'),
(228,9,'Amreli','Amreli'),
(229,9,'Anand','Anand'),
(230,9,'Aravalli','Aravalli'),
(231,9,'Banaskantha','Banaskantha'),
(232,9,'Bharuch','Bharuch'),
(233,9,'Bhavnagar','Bhavnagar'),
(234,9,'Botad','Botad'),
(235,9,'Chhota Udaipur','Chhota_Udaipur'),
(236,9,'Dahod','Dahod'),
(237,9,'Dang','Dang'),
(238,9,'Devbhumi Dwarka','Devbhumi_Dwarka'),
(239,9,'Gandhinagar','Gandhinagar'),
(240,9,'Gir Somnath','Gir_Somnath'),
(241,9,'Jamnagar','Jamnagar'),
(242,9,'Junagarh','Junagarh'),
(243,9,'Kheda','Kheda'),
(244,9,'Kachchh','Kachchh'),
(245,9,'Mahisagar','Mahisagar'),
(246,9,'Mehsana','Mehsana'),
(247,9,'Morbi','Morbi'),
(248,9,'Narmada','Narmada'),
(249,9,'Navsari','Navsari'),
(250,9,'Panch mahal','Panch_mahal'),
(251,9,'Patan','Patan'),
(252,9,'Porbandar','Porbandar'),
(253,9,'Rajkot','Rajkot'),
(254,9,'Sabarkantha','Sabarkantha'),
(255,9,'Surat','Surat'),
(256,9,'Surendranagar','Surendranagar'),
(257,9,'Tapi','Tapi'),
(258,9,'Vadodara','Vadodara'),
(259,9,'Valsad','Valsad'),
(260,10,'Ambala','Ambala'),
(261,10,'Bhiwani','Bhiwani'),
(262,10,'Charkhi Dadri','Charkhi_Dadri'),
(263,10,'Faridabad','Faridabad'),
(264,10,'Fatehabad','Fatehabad'),
(265,10,'Gurugram','Gurugram'),
(266,10,'Hisar','Hisar'),
(267,10,'Jhajjar','Jhajjar'),
(268,10,'Jind','Jind'),
(269,10,'Kaithal','Kaithal'),
(270,10,'Karnal','Karnal'),
(271,10,'Kurukshetra','Kurukshetra'),
(272,10,'Mahendragarh','Mahendragarh'),
(273,10,'Nuh','Nuh'),
(274,10,'Palwal','Palwal'),
(275,10,'Panchkula','Panchkula'),
(276,10,'Panipat','Panipat'),
(277,10,'Rewari','Rewari'),
(278,10,'Rohtak','Rohtak'),
(279,10,'Sirsa','Sirsa'),
(280,10,'Sonipat','Sonipat'),
(281,10,'Yamunanagar','Yamunanagar'),
(282,11,N'Bilaspur(HP)','Bilaspur_HP'),
(283,11,'Chamba','Chamba'),
(284,11,N'Hamirpur(HP)','Hamirpur_HP'),
(285,11,'Kangra','Kangra'),
(286,11,'Kinnaur','Kinnaur'),
(287,11,'Kullu','Kullu'),
(288,11,'Lahul and Spiti','Lahul_and_Spiti'),
(289,11,'Mandi','Mandi'),
(290,11,'Shimla','Shimla'),
(291,11,'Sirmaur','Sirmaur'),
(292,11,'Solan','Solan'),
(293,11,'Una','Una'),
(294,12,'Bokaro','Bokaro'),
(295,12,'Chatra','Chatra'),
(296,12,'Deoghar','Deoghar'),
(297,12,'Dhanbad','Dhanbad'),
(298,12,'Dumka','Dumka'),
(299,12,'East Singhbum','East_Singhbum'),
(300,12,'Garhwa','Garhwa'),
(301,12,'Giridih','Giridih'),
(302,12,'Godda','Godda'),
(303,12,'Gumla','Gumla'),
(304,12,'Hazaribagh','Hazaribagh'),
(305,12,'Jamtara','Jamtara'),
(306,12,'Khunti','Khunti'),
(307,12,'Koderma','Koderma'),
(308,12,'Latehar','Latehar'),
(309,12,'Lohardaga','Lohardaga'),
(310,12,'Pakur','Pakur'),
(311,12,'Palamu','Palamu'),
(312,12,'Ramgarh','Ramgarh'),
(313,12,'Ranchi','Ranchi'),
(314,12,'Sahebganj','Sahebganj'),
(315,12,'Saraikela Kharsawan','Saraikela_Kharsawan'),
(316,12,'Simdega','Simdega'),
(317,12,'West Singhbhum','West_Singhbhum'),
(318,13,'Alappuzha','Alappuzha'),
(319,13,'Ernakulam','Ernakulam'),
(320,13,'Idukki','Idukki'),
(321,13,'Kannur','Kannur'),
(322,13,'Kasaragod','Kasaragod'),
(323,13,'Kollam','Kollam'),
(324,13,'Kottayam','Kottayam'),
(325,13,'Kozhikode','Kozhikode'),
(326,13,'Malappuram','Malappuram'),
(327,13,'Palakkad','Palakkad'),
(328,13,'Pathanamthitta','Pathanamthitta'),
(329,13,'Thiruvananthapuram','Thiruvananthapuram'),
(330,13,'Thrissur','Thrissur'),
(331,13,'Wayanad','Wayanad'),
(332,14,'Agar Malwa','Agar_Malwa'),
(333,14,'Alirajpur','Alirajpur'),
(334,14,'Anuppur','Anuppur'),
(335,14,'Ashoknagar','Ashoknagar'),
(336,14,'Balaghat','Balaghat'),
(337,14,'Barwani','Barwani'),
(338,14,'Betul','Betul'),
(339,14,'Bhind','Bhind'),
(340,14,'Bhopal','Bhopal'),
(341,14,'Burhanpur','Burhanpur'),
(342,14,'Chhatarpur','Chhatarpur'),
(343,14,'Chhindwara','Chhindwara'),
(344,14,'Damoh','Damoh'),
(345,14,'Datia','Datia'),
(346,14,'Dewas','Dewas'),
(347,14,'Dhar','Dhar'),
(348,14,'Dindori','Dindori'),
(349,14,'East Nimar','East_Nimar'),
(350,14,'Guna','Guna'),
(351,14,'Gwalior','Gwalior'),
(352,14,'Harda','Harda'),
(353,14,'Indore','Indore'),
(354,14,'Jabalpur','Jabalpur'),
(355,14,'Jhabua','Jhabua'),
(356,14,'Katni','Katni'),
(357,14,'Khargone','Khargone'),
(358,14,'Mandla','Mandla'),
(359,14,'Mandsaur','Mandsaur'),
(360,14,'Mauganj','Mauganj'),
(361,14,'Morena','Morena'),
(362,14,'Narmadapuram','Narmadapuram'),
(363,14,'Narsinghpur','Narsinghpur'),
(364,14,'Neemuch','Neemuch'),
(365,14,'Niwari','Niwari'),
(366,14,'Panna','Panna'),
(367,14,'Raisen','Raisen'),
(368,14,'Rajgarh','Rajgarh'),
(369,14,'Ratlam','Ratlam'),
(370,14,'Rewa','Rewa'),
(371,14,'Sagar','Sagar'),
(372,14,'Satna','Satna'),
(373,14,'Sehore','Sehore'),
(374,14,'Seoni','Seoni'),
(375,14,'Shahdol','Shahdol'),
(376,14,'Shajapur','Shajapur'),
(377,14,'Sheopur','Sheopur'),
(378,14,'Umaria','Umaria'),
(379,14,'Vidisha','Vidisha'),
(380,14,'Shivpuri','Shivpuri'),
(381,14,'Sidhi','Sidhi'),
(382,14,'Singrauli','Singrauli'),
(383,14,'Tikamgarh','Tikamgarh'),
(384,14,'Ujjain','Ujjain'),
(385,15,'Bishnupur','Bishnupur'),
(386,15,'Chandel','Chandel'),
(387,15,'Churachandpur','Churachandpur'),
(388,15,'Imphal East','Imphal_East'),
(389,15,'Imphal West','Imphal_West'),
(390,15,'Jiribam','Jiribam'),
(391,15,'Kakching','Kakching'),
(392,15,'Kamjong','Kamjong'),
(393,15,'Kangpokpi','Kangpokpi'),
(394,15,'Noney','Noney'),
(395,15,'Pherzawl','Pherzawl'),
(396,15,'Senapati','Senapati'),
(397,15,'Tamenglong','Tamenglong'),
(398,15,'Tengnoupal','Tengnoupal'),
(399,15,'Thoubal','Thoubal'),
(400,15,'Ukhrul','Ukhrul'),
(401,16,'East Garo Hills','East_Garo_Hills'),
(402,16,'East Jaintia Hills','East_Jaintia_Hills'),
(403,16,'East Khasi Hills','East_Khasi_Hills'),
(404,16,'Eastern West Khasi Hills','Eastern_West_Khasi_Hills'),
(405,16,'North Garo Hills','North_Garo_Hills'),
(406,16,'Ri Bhoi','Ri_Bhoi'),
(407,16,'South Garo Hills','South_Garo_Hills'),
(408,16,'South West Garo Hills','South_West_Garo_Hills'),
(409,16,'South West Khasi Hills','South_West_Khasi_Hills'),
(410,16,'West Garo Hills','West_Garo_Hills'),
(411,16,'West Jaintia Hills','West_Jaintia_Hills'),
(412,16,'West Khasi Hills','West_Khasi_Hills'),
(413,17,'Aizawl','Aizawl'),
(414,17,'Champhai','Champhai'),
(415,17,'Hnahthial','Hnahthial'),
(416,17,'Khawzawl','Khawzawl'),
(417,17,'Kolasib','Kolasib'),
(418,17,'Lawngtlai','Lawngtlai'),
(419,17,'Lunglei','Lunglei'),
(420,17,'Mamit','Mamit'),
(421,17,'Saiha','Saiha'),
(422,17,'Saitual','Saitual'),
(423,17,'Serchhip','Serchhip'),
(424,18,'Chumoukedima','Chumoukedima'),
(425,18,'Dimapur','Dimapur'),
(426,18,'Kiphire','Kiphire'),
(427,18,'Kohima','Kohima'),
(428,18,'Longleng','Longleng'),
(429,18,'Mokokchung','Mokokchung'),
(430,18,'Mon','Mon'),
(431,18,'Niuland','Niuland'),
(432,18,'Noklak','Noklak'),
(433,18,'Peren','Peren'),
(434,18,'Phek','Phek'),
(435,18,'Shamator','Shamator'),
(436,18,'Tseminyu','Tseminyu'),
(437,18,'Tuensang','Tuensang'),
(438,18,'Wokha','Wokha'),
(439,18,'Zunheboto','Zunheboto'),
(440,19,'Anugul','Anugul'),
(441,19,'Balangir','Balangir'),
(442,19,'Baleshwar','Baleshwar'),
(443,19,'Bargarh','Bargarh'),
(444,19,'Bhadrak','Bhadrak'),
(445,19,'Boudh','Boudh'),
(446,19,'Cuttack','Cuttack'),
(447,19,'Deogarh','Deogarh'),
(448,19,'Dhenkanal','Dhenkanal'),
(449,19,'Gajapati','Gajapati'),
(450,19,'Ganjam','Ganjam'),
(451,19,'Jagatsinghapur','Jagatsinghapur'),
(452,19,'Jajapur','Jajapur'),
(453,19,'Jharsuguda','Jharsuguda'),
(454,19,'Kalahandi','Kalahandi'),
(455,19,'Kandhamal','Kandhamal'),
(456,19,'Kendrapara','Kendrapara'),
(457,19,'Kendujhar','Kendujhar'),
(458,19,'Khordha','Khordha'),
(459,19,'Koraput','Koraput'),
(460,19,'Malkangiri','Malkangiri'),
(461,19,'Mayurbhanj','Mayurbhanj'),
(462,19,'Nabarangpur','Nabarangpur'),
(463,19,'Nayagarh','Nayagarh'),
(464,19,'Nuapada','Nuapada'),
(465,19,'Puri','Puri'),
(466,19,'Rayagada','Rayagada'),
(467,19,'Sambalpur','Sambalpur'),
(468,19,'Sonepur','Sonepur'),
(469,19,'Sundargarh','Sundargarh'),
(470,20,'Amritsar','Amritsar'),
(471,20,'Barnala','Barnala'),
(472,20,'Bathinda','Bathinda'),
(473,20,'Faridkot','Faridkot'),
(474,20,'Fatehgarh Sahib','Fatehgarh_Sahib'),
(475,20,'Fazilka','Fazilka'),
(476,20,'Ferozepur','Ferozepur'),
(477,20,'Gurdaspur','Gurdaspur'),
(478,20,'Hoshiarpur','Hoshiarpur'),
(479,20,'Jalandhar','Jalandhar'),
(480,20,'Kapurthala','Kapurthala'),
(481,20,'Ludhiana','Ludhiana'),
(482,20,'Malerkotla','Malerkotla'),
(483,20,'Mansa','Mansa'),
(484,20,'Moga','Moga'),
(485,20,'Pathankot','Pathankot'),
(486,20,'Patiala','Patiala'),
(487,20,'Rupnagar','Rupnagar'),
(488,20,N'S.A.S Nagar','S_A_S_Nagar'),
(489,20,'Sangrur','Sangrur'),
(490,20,'Shahid Bhagat Singh Nagar','Shahid_Bhagat_Singh_Nagar'),
(491,20,'Sri Muktsar Sahib','Sri_Muktsar_Sahib'),
(492,20,'Tarn Taran','Tarn_Taran'),
(493,21,'Gangtok','Gangtok'),
(494,21,'Gyalshing','Gyalshing'),
(495,21,'Mangan','Mangan'),
(496,21,'Namchi','Namchi'),
(497,21,'Pakyong','Pakyong'),
(498,21,'Soreng','Soreng'),
(499,22,'Ariyalur','Ariyalur'),
(500,22,'Chengalpattu','Chengalpattu'),
(501,22,'Chennai','Chennai'),
(502,22,'Coimbatore','Coimbatore'),
(503,22,'Cuddalore','Cuddalore'),
(504,22,'Dharmapuri','Dharmapuri'),
(505,22,'Dindigul','Dindigul'),
(506,22,'Erode','Erode'),
(507,22,'Kallakurichi','Kallakurichi'),
(508,22,'Kanchipuram','Kanchipuram'),
(509,22,'Kanniyakumari','Kanniyakumari'),
(510,22,'Karur','Karur'),
(511,22,'Krishnagiri','Krishnagiri'),
(512,22,'Madurai','Madurai'),
(513,22,'Mayiladuthurai','Mayiladuthurai'),
(514,22,'Nagapattinam','Nagapattinam'),
(515,22,'Namakkal','Namakkal'),
(516,22,'Perambalur','Perambalur'),
(517,22,'Pudukkottai','Pudukkottai'),
(518,22,'Ramanathapuram','Ramanathapuram'),
(519,22,'Ranipet','Ranipet'),
(520,22,'Salem','Salem'),
(521,22,'Sivaganga','Sivaganga'),
(522,22,'Tenkasi','Tenkasi'),
(523,22,'Thanjavur','Thanjavur'),
(524,22,'Theni','Theni'),
(525,22,'The Nilgiris','The_Nilgiris'),
(526,22,'Thiruvallur','Thiruvallur'),
(527,22,'Thiruvarur','Thiruvarur'),
(528,22,'Tiruchirappalli','Tiruchirappalli'),
(529,22,'Tirunelveli','Tirunelveli'),
(530,22,'Tirupathur','Tirupathur'),
(531,22,'Tiruppur','Tiruppur'),
(532,22,'Tiruvannamalai','Tiruvannamalai'),
(533,22,'Tuticorin','Tuticorin'),
(534,22,'Vellore','Vellore'),
(535,22,'Villupuram','Villupuram'),
(536,22,'Virudhunagar','Virudhunagar'),
(537,23,'Adilabad','Adilabad'),						
(538,23,'Bhadradri Kothagudem','Bhadradri_Kothagudem'),			
(539,23,'Hanumakonda','Hanumakonda'),						
(540,23,'Hyderabad','Hyderabad'),						
(541,23,'Jagitial','Jagitial'),						
(542,23,'Jangoan','Jangoan'),						
(543,23,'Jayashankar Bhupalapally','Jayashankar_Bhupalapally'),					
(544,23,'Jogulamba Gadwal','Jogulamba Gadwal'),						
(545,23,'Kamareddy','Kamareddy'),						
(546,23,'Karimnagar','Karimnagar'),						
(547,23,'Khammam','Khammam'),						
(548,23,'Kumuram Bheem Asifabad','Kumuram_Bheem_Asifabad'),				
(549,23,'MahabubNagar','MahabubNagar'),						
(550,23,'Mahabubabad','Mahabubabad'),						
(551,23,'Mancherial','Mancherial'),						
(552,23,'Medak','Medak'),						
(553,23,'Medchal Malkajgiri','Medchal_Malkajgiri'),						
(554,23,'Mulugu','Mulugu'),						
(555,23,'Nagarkurnool','Nagarkurnool'),						
(556,23,'Nalgonda','Nalgonda'),						
(557,23,'Narayanpet','Narayanpet'),						
(558,23,'Nirmal','Nirmal'),						
(559,23,'Nizamabad','Nizamabad'),						
(560,23,'Peddapalli','Peddapalli'),						
(561,23,'Rajanna Sircilla ','Rajanna_Sircilla'),						
(562,23,'Ranga Reddy','Ranga_Reddy'),						
(563,23,'Sangareddy','Sangareddy'),						
(564,23,'Siddipet','Siddipet'),						
(565,23,'Suryapet','Suryapet'),						
(566,23,'Vikarabad','Vikarabad'),						
(567,23,'Wanaparthy','Wanaparthy'),						
(568,23,'Warangal','Warangal'),						
(569,23,'Yadadri Bhuvanagir','Yadadri_Bhuvanagir'),
(570,24,'Dhalai','Dhalai'),
(571,24,'Gomati','Gomati'),
(572,24,'Khowai','Khowai'),
(573,24,'North Tripura','North_Tripura'),
(574,24,'Sepahijala','Sepahijala'),
(575,24,'South Tripura','South_Tripura'),
(576,24,'Unakoti','Unakoti'),
(577,24,'West Tripura','West_Tripura'),
(578,25,'Almora','Almora'),
(579,25,'Bageshwar','Bageshwar'),
(580,25,'Chamoli','Chamoli'),
(581,25,'Champawat','Champawat'),
(582,25,'Dehradun','Dehradun'),
(583,25,'Haridwar','Haridwar'),
(584,25,'Nainital','Nainital'),
(585,25,'Pauri Garhwal','Pauri_Garhwal'),
(586,25,'Pithoragarh','Pithoragarh'),
(587,25,'Rudra Prayag','Rudra_Prayag'),
(588,25,'Tehri Garhwal','Tehri_Garhwal'),
(589,25,'Udam Singh Nagar','Udam_Singh_Nagar'),
(590,25,'Uttar Kashi','Uttar_Kashi'),
(591,26,'Agra','Agra'),
(592,26,'Aligarh','Aligarh'),
(593,26,'Ambedkar Nagar','Ambedkar_Nagar'),
(594,26,'Amethi','Amethi'),
(595,26,'Amroha','Amroha'),
(596,26,'Auraiya','Auraiya'),
(597,26,'Ayodhya','Ayodhya'),
(598,26,'Azamgarh','Azamgarh'),
(599,26,'Baghpat','Baghpat'),
(600,26,'Bahraich','Bahraich'),
(601,26,'Ballia','Ballia'),
(602,26,'Balrampur','Balrampur'),
(603,26,'Banda','Banda'),
(604,26,'Barabanki','Barabanki'),
(605,26,'Bareilly','Bareilly'),
(606,26,'Basti','Basti'),
(607,26,'Bhadohi','Bhadohi'),
(608,26,'Bijnor','Bijnor'),
(609,26,'Budaun','Budaun'),
(610,26,'Bulandshahr','Bulandshahr'),
(611,26,'Chandauli','Chandauli'),
(612,26,'Chitrakoot','Chitrakoot'),
(613,26,'Deoria','Deoria'),
(614,26,'Etah','Etah'),
(615,26,'Etawah','Etawah'),
(616,26,'Kannauj','Kannauj'),
(617,26,'Kanpur Dehat','Kanpur_Dehat'),
(618,26,'Kanpur Nagar','Kanpur_Nagar'),
(619,26,'Kasganj','Kasganj'),
(620,26,'Kaushambi','Kaushambi'),
(621,26,'Kheri','Kheri'),
(622,26,'Kushi Nagar','Kushi_Nagar'),
(623,26,'Lalitpur','Lalitpur'),
(624,26,'Lucknow','Lucknow'),
(625,26,'Maharajganj','Maharajganj'),
(626,26,'Mahoba','Mahoba'),
(627,26,'Mainpuri','Mainpuri'),
(628,26,'Mathura','Mathura'),
(629,26,'Mau','Mau'),
(630,26,'Meerut','Meerut'),
(631,26,'Farrukhabad','Farrukhabad'),
(632,26,'Fatehpur','Fatehpur'),
(633,26,'Firozabad','Firozabad'),
(634,26,'Gautam Buddha Nagar','Gautam_Buddha_Nagar'),
(635,26,'Ghaziabad','Ghaziabad'),
(636,26,'Ghazipur','Ghazipur'),
(637,26,'Gonda','Gonda'),
(638,26,'Gorakhpur','Gorakhpur'),
(639,26,'Hamirpur','Hamirpur'),
(640,26,'Hapur','Hapur'),
(641,26,'Mirzapur','Mirzapur'),
(642,26,'Moradabad','Moradabad'),
(643,26,'Muzaffarnagar','Muzaffarnagar'),
(644,26,'Pilibhit','Pilibhit'),
(645,26,'Pratapgarh','Pratapgarh'),
(646,26,'Prayagraj','Prayagraj'),
(647,26,'Rae Bareli','Rae_Bareli'),
(648,26,'Rampur','Rampur'),
(649,26,'Saharanpur','Saharanpur'),
(650,26,'Sambhal','Sambhal'),
(651,26,'Sant Kabeer Nagar','Sant_Kabeer_Nagar'),
(652,26,'Shahjahanpur','Shahjahanpur'),
(653,26,'Shamli','Shamli'),
(654,26,'Shravasti','Shravasti'),
(655,26,'Siddharth Nagar','Siddharth_Nagar'),
(656,26,'Sitapur','Sitapur'),
(657,26,'Sonbhadra','Sonbhadra'),
(658,26,'Sultanpur','Sultanpur'),
(659,26,'Unnao','Unnao'),
(660,26,'Varanasi','Varanasi'),
(661,26,'Hardoi','Hardoi'),
(662,26,'Hathras','Hathras'),
(663,26,'Jalaun','Jalaun'),
(664,26,'Jaunpur','Jaunpur'),
(665,26,'Jhansi','Jhansi'),
(666,27,N'24 Paraganas North','24_Paraganas_North'),
(667,27,N'24 Paraganas South','24_Paraganas_South'),
(668,27,'Alipurduar','Alipurduar'),
(669,27,'Bankura','Bankura'),
(670,27,'Birbhum','Birbhum'),
(671,27,'Coochbehar','Coochbehar'),
(672,27,'Darjeeling','Darjeeling'),
(673,27,'Dinajpur Dakshin','Dinajpur_Dakshin'),
(674,27,'Dinajpur Uttar','Dinajpur_Uttar'),
(675,27,'Hooghly','Hooghly'),
(676,27,'Howrah','Howrah'),
(677,27,'Jalpaiguri','Jalpaiguri'),
(678,27,'Jhargram','Jhargram'),
(679,27,'Kalimpong','Kalimpong'),
(680,27,'Kolkata','Kolkata'),
(681,27,'Maldah','Maldah'),
(682,27,'Medinipur East','Medinipur_East'),
(683,27,'Medinipur West','Medinipur_West'),
(684,27,'Murshidabad','Murshidabad'),
(685,27,'Nadia','Nadia'),
(686,27,'Paschim Bardhaman','Paschim Bardhaman'),
(687,27,'Purba Bardhaman','Purba Bardhaman'),
(688,27,'Purulia','Purulia'),
(689,28,'Ajmer','Ajmer'),
(690,28,'Alwar','Alwar'),
(691,28,'Banswara','Banswara'),
(692,28,'Baran','Baran'),
(693,28,'Barmer','Barmer'),
(694,28,'Bharatpur','Bharatpur'),
(695,28,'Bhilwara','Bhilwara'),
(696,28,'Bikaner','Bikaner'),
(697,28,'Bundi','Bundi'),
(698,28,'Chittorgarh','Chittorgarh'),
(699,28,'Churu','Churu'),
(700,28,'Dausa','Dausa'),
(701,28,'Dholpur','Dholpur'),
(702,28,'Dungarpur','Dungarpur'),
(703,28,'Ganganagar','Ganganagar'),
(704,28,'Hanumangarh','Hanumangarh'),
(705,28,'Jaipur','Jaipur'),
(706,28,'Jaisalmer','Jaisalmer'),
(707,28,'Jalore','Jalore'),
(708,28,'Jhalawar','Jhalawar'),
(709,28,'Jhunjhunu','Jhunjhunu'),
(710,28,'Jodhpur','Jodhpur'),
(711,28,'Karauli','Karauli'),
(712,28,'Kota','Kota'),
(713,28,'Nagaur','Nagaur'),
(714,28,'Pali','Pali'),
(715,28,'Pratapgarh','Pratapgarh'),
(716,28,'Rajsamand','Rajsamand'),
(717,28,'Sawai Madhopur','Sawai_Madhopur'),
(718,28,'Sikar','Sikar'),
(719,28,'Sirohi','Sirohi'),
(720,28,'Tonk','Tonk'),
(721,28,'Udaipur','Udaipur'),
 (722,29,'Nicobars','Nicobars'),
 (723,29,'North And Middle Andaman','North_And_Middle_Andaman'),
 (724,29,'South Andam','South_Andam'),
 (725,30,'Dadra and Nagar Haveli','Dadra_and_Nagar_Haveli'),
(726,30,'Daman','Daman'),
(727,30,'Diu','Diu'),
(728,31,'Central Delhi','Central_Delhi'),
(729,31,'East Delhi','East_Delhi'),
(730,31,'New Delhi','New_Delhi'),
(731,31,'North Delhi District','North_Delhi_District'),
(732,31,'North East Delhi','North_East_Delhi'),
(733,31,'North West Delhi','North_West_Delhi'),
(734,31,'Shahdara','Shahdara'),
(735,31,'South Delhi','South_Delhi'),
(736,31,'South East Delhi','South East Delhi'),
(737,31,'South West Delhi','South_West_Delhi'),
(738,31,'West Delhi','West_Delhi'),
(739,32,'Anantnag','Anantnag'),
(740,32,'Bandipora','Bandipora'),
(741,32,'Baramulla','Baramulla'),
(742,32,'Budgam','Budgam'),
(743,32,'Doda','Doda'),
(744,32,'Ganderbal','Ganderbal'),
(745,32,'Jammu','Jammu'),
(746,32,'Kathua','Kathua'),
(747,32,'Kishtwar','Kishtwar'),
(748,32,'Kulgam','Kulgam'),
(749,32,'Kupwara','Kupwara'),
(750,32,'Poonch','Poonch'),
(751,32,'Pulwama','Pulwama'),
(752,32,'Rajouri','Rajouri'),
(753,32,'Ramban','Ramban'),
(754,32,'Reasi','Reasi'),
(755,32,'Samba','Samba'),
(756,32,'Shopian','Shopian'),
(757,32,'Srinagar','Srinagar'),
(758,32,'Udhampur','Udhampur'),
(759,33,'Leh Ladakh ','Leh_Ladakh'),
(760,33,'Kargil','Kargil'),
(761,34,'Lakshadweep District','Lakshadweep_District'),
(762,35,'Karaikal','Karaikal'),
(763,35,'Mahe','Mahe'),
(764,35,'Pondicherry','Pondicherry'),
(765,35,'Yanam','Yanam');

MERGE INTO District AS Target USING @District AS Source ON Source.DistrictId = Target.DistrictId WHEN MATCHED THEN 
UPDATE 
SET 
  Target.DistrictName = Source.DistrictName, 
  Target.DistrictKey = Source.DistrictKey, 
  Target.StateId = Source.StateId WHEN NOT MATCHED THEN INSERT(
    DistrictId, StateId, DistrictName, 
    DistrictKey
  ) 
VALUES 
  (
    Source.DistrictId, Source.StateId, 
    Source.DistrictName, Source.DistrictKey
  );
