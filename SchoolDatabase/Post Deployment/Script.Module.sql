/*
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

DECLARE @Module TABLE([ModuleId] INT,[Name] NVARCHAR(250),[ModuleKey] NVARCHAR(250),[ParentId] INT,[MenuTypeId] INT,
                      [MenuUrl]  NVARCHAR(250),[MenuIcon] NVARCHAR(50),[MenuSort] INT);

INSERT INTO @Module([ModuleId],[Name],[ModuleKey],[ParentId],[MenuTypeId],
                    [MenuUrl],[MenuIcon],[MenuSort])
                                 VALUES(1,'Dashboard','Dashboard',NULL,1,'/dashboard','bi bi-grid',1),
                                       (2,'School','School',NULL,1,NULL,'bi bi-bank',2),
                                       (20,'School Profile','School_Profile',2,2,'/school-profile','bi bi-bank',201),
                                       (21,'School Settings','School_Settings',2,2,'/school-settings','bi bi-bank',202),
                                       (3,'School Staff','School_Staff',NULL,1,NULL,'bi bi-person',5),
                                       (4,'Admin','Admin',3,2,'/admins',NULL,501),
                                       (5,'Teacher','Teacher',3,2,'/teachers',NULL,502),
                                       (6,'Clerk','Clerk',3,2,'/clerks',NULL,503),
                                       (7,'Cab Driver','Cab_Driver',3,2,'/cab-drivers',NULL,504),
                                       (8,'Access','Access',3,2,'/user-access',NULL,599),
                                       (9,'Parent','Parent',NULL,1,'/parents','bi bi-person-vcard',4),
                                       (10,'Student','Student',NULL,1,NULL,'bi bi-people',3),
                                       (11,'Students','Students',10,2,'/students',NULL,302),
                                       (12,'Leaving','Leaving',37,2,'/student-certificates/student-leaving-certificate',NULL,1101),
                                       (13,'Promote','Promote',10,2,'/students/promote-student',NULL,304),

                                       (16,'Fee Management','Academic_Fee_Management',NULL,1,NULL,'bi bi-credit-card',6),
                                       (17,'Academic Fee Structure','Academic_Fee_Structure',16,2,'/fee-management/view-fee-structure',NULL,602),
                                       (18,'Academic Fee Payment','Academic_Fee_Payment',16,2,'/fee-management/view-payment',NULL,603),
                                       (22,'Fee Waiver Master','Fee_Waiver_Master',16,2,'/fee-management/fee-waiver-master',NULL,601),
                                       (46,'Payment Analytic','Payment_Analytic_Menu',16,2,'/fee-management/payment-analytic',NULL,604),
                                       (62,'Payment Collection Report','Payment_Collection_Report_Menu',16,2,'/fee-management/payment-collection-report',NULL,605),

                                       (24,'Notifications','Notifications',NULL,1,NULL,'bi bi-bell-fill',7),
                                       (25,'Notice','Notice',24,2,'/notice',NULL,702),
                                       (26,'Homework','Homework',24,2,'/homework',NULL,701),
                                       (27,'Masters','Masters',NULL,1,NULL,'bi bi-building-gear',8),
                                       (28,'Grade','Grade',27,2,'/grade-master',NULL,801),
                                       (29,'Division','Division',27,2,'/division-master',NULL,802),
                                       (30,'Grade Division Matrix','Grade_Division_Matrix',27,2,'/grade-master/grade-division-matrix',NULL,803),
                                       (31,'Subject','Subject',NULL,1,NULL,'bi bi-book',9),
                                       (32,'Timetable','Timetable',NULL,1,Null,'bi bi-calendar',10),
                                       (33,'Manage Timetable','Manage_Timetable',32,2,'/timetable/manage-timetable',NULL, 1001),
                                       (34,'Teacher Timetable','Teacher_Timetable',32,3,'/timetable/teacher-timetable',NULL, 1002),
                                       (35,'Class Timetable','Class_Timetable',32,4,'/timetable/class-timetable',NULL, 1003),
                                       (37,'Certificates','Certificate',NULL,1,NULL,'bi bi-file-text', 11),
                                       (38,'Bonafied','Bonafied',37,2,'/student-certificates/student-bonafied-certificate',NULL,1102),
                                       (39,'Character','Character',37,2,'/student-certificates/student-character-certificate',NULL,1103),
                                       
                                       (41,'ID Card','ID_CARD',37,2,'/student-certificates/student-idcard-certificate',NULL,1105),
                                       (42,'Attendance','Attendance',NULL,1,NULL,'bi bi-people',12),
                                       (43,'Student Attendance','Student_Attendance',42,2,'/attendance',NULL,1201),
                                       (44,'Student Attendance Report','Student_Attendance_Report',42,2,'/report/student-attendance-report',NULL,1202),
                                       (45,'Class-wise Attendance Report','Class-wise_Attendance_Report',42,2,'/report/class-attendance-report',NULL,1203),
                                       (83,'Bulk Attendance Update','Bulk_Attendance_Update',42,2,'/attendance/class-attendance-status',NULL,1204),

                                       
                                       (47,'Calendar','Calendar',NULL,1,NULL,'bi bi-file-text', 13),
                                       (48,'School Calendar','School_Calendar',47,2,'/school-calendar',NULL,1301),
                                       (49,'School Holiday','School_Holiday',47,2,'/school-calendar/school-holiday',NULL,1302),
                                       (50,'Events','Events',47,2,'/school-calendar/school-event',NULL,1303),
                                       (51,'Class-Teacher Mapping','Class-Teacher_Mapping',27,2,'/teachers/teacher-grade-division-mapping',NULL,804),
                                       (52,'Subject Master','Subject_Master',31,2,'/subject/subject-master','bi bi-book',901),
                                       (53,'Class-Subject Mapping','Class-Subject_Mapping',31,2,'/subject/subject-mapping','bi bi-book',902),
                                       (54,'Teacher-Subject Mapping','Teacher-Subject_Mapping',31,2,'/subject/teacher-subject-mapping','bi bi-book',903),
                                       
                                       (56,'Transport','Transport_Management_Menu',NULL,1,NULL,'bi bi-bus-front', 14),
                                       (57,'Vehicle Management','Vehicle_Management',56,2,'/transport/vehicle',NULL,1401),
                                       (58,'Area Management','Area_Management',56,2,'/transport/area',NULL,1402),
                                       (59,'Route Management','Route_Management_Menu',56,2,'/transport/route',NULL,1403),
                                       (63,'Transport Fee Payment','Transport_Fee_Payment',56,2,'/transport-fee-management/transport-view-payment',NULL,1404),
                                       (64,'Transport Payment Summary','Transport_Payment_Summary_Menu',56,2,'/transport-fee-management/transport-payment-analytics',NULL,1405),
                                       (65,'Transport Payment Collection','Transport_Payment_Collection_Menu',56,2,'/transport-fee-management/transport-payment-daywise-report',NULL,1406),
                                       
                                       (66,'Additional Fee Management','Additional_Fee_Management_Menu',NULL,1,NULL,'bi bi-credit-card',16),
                                       (55,'Additional Fee Payment','Additional_Fee_Payment',66,2,'/adhoc-fee-management/adhoc-view-payment',NULL,1601),
                                       (67,'Additional Payment Collection','Additional_Payment_Collection_Menu',66,2,'/adhoc-fee-management/adhoc-payment-collection-report',NULL,1602),

                                       (68,'Student Kit Fee Management','Student_Kit_Fee_Management_Menu',NULL,1,NULL,'bi bi-credit-card',17),
                                       (19,'Student Kit Fee Structure','Student_Kit_Fee_Structure',68,2,'/fee-management/view-student-kit-fee-structure',NULL,1701),
                                       (70,'Student Kit Fee Payment','Student_Kit_Fee_Payment_Menu',68,2,'/student-kit-fee-management/view-student-kit-payment',NULL,1702),
                                       (71,'Student Kit Payment Summary','Student_Kit_Payment_Summary_Menu',68,2,'/student-kit-fee-management/student-kit-payment-analytics',NULL,1703),
                                       (72,'Student Kit Payment Collection','Student_Kit_Payment_Collection_Menu',68,2,'/student-kit-fee-management/student-kit-payment-daywise-report',NULL,1704),

                                       (73,'Student Reports','Student_Reports',10,2,'/students/student-report',NULL,303),
                                       (74,'Gallery','Gallery',24,2,'/gallery',NULL,703),

                                       (75, 'Enquiries', 'Enquiries', NULL, 1, NULL, 'bi bi-file-text', 18),
                                       (76,'Admission Enquiries','Admission Enquiries',75,2,'/students/student-enquiry',NULL,1801),

                                       (77,'Exam & Results', 'Exam & Results', NULL, 1, NULL, 'bi bi-file-text', 19),
                                       (78,'Exam Master','Exam Master',77,2,'/cbse-exam/exam-master',NULL,1901),
                                       (79,'Exam Object','Exam Object',77,2,'/cbse-exam/exam-object',NULL,1902),
                                       (80,'Exam-Class Mapping','Exam-Class Mapping',77,2,'/cbse-exam/exam-mapping',NULL,1903),
                                       (81,'Mark-Grade Mapping','Grade-Mark Mapping',77,2,'/cbse-exam/marks-grade-relation',NULL,1904),
                                       (82,'Exam-Mark Mapping','Exam-Mark Mapping',77,2,'/cbse-exam-result',NULL,1905),
                                       (84,'Exam Report Card Template','Exam Report Card Template',77,2,'/cbse-exam/exam-reportcard-template',NULL,1906),
                                       (85,'Exam Assessment Report','Exam Assessment Report',77,2,'/cbse-academic-assessment-report/academic-assessment-report',NULL,1907)


                                       





                                       ;
                                       --(60,'Survey','Survey',NULL,1,NULL,'bi bi-pen-fill', 20),
                                       --(61,'Survey Management','Survey_Management',60,2,'/survey',NULL,2001),
                                      --(40,'Health','Health',37,2,'/student-certificates/student-health-certificate',NULL,1104),

MERGE INTO dbo.Module AS Target
USING @Module AS Source 
ON Source.ModuleId=Target.ModuleId
WHEN MATCHED THEN
UPDATE SET target.Name=source.Name,target.ModuleKey=source.ModuleKey,target.ParentId=source.ParentId,
           target.MenuTypeId=source.MenuTypeId,target.MenuUrl=source.MenuUrl,
           target.MenuIcon=source.MenuIcon,target.MenuSort=source.MenuSort
WHEN NOT MATCHED THEN
INSERT([ModuleId],[Name],[ModuleKey],[ParentId],[MenuTypeId],
                    [MenuUrl],[MenuIcon],[MenuSort]) VALUES(source.ModuleId,source.Name,Source.ModuleKey,source.ParentId,source.MenuTypeId,source.MenuUrl,
                    source.MenuIcon,source.MenuSort);

DELETE rp FROM dbo.RolePermission rp
WHERE  NOT EXISTS (SELECT ModuleId FROM @Module WHERE ModuleId=rp.ModuleId);

DELETE m FROM dbo.Module m
WHERE  NOT EXISTS (SELECT ModuleId FROM @Module WHERE ModuleId=m.ModuleId);
                    