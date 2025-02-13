create database scheduleapp;
\c scheduleapp;

CREATE TABLE all_User (
  Id_user  serial NOT NULL UNIQUE,
  Surname  varchar(40) NOT NULL, 
  Name     varchar(40) NOT NULL,
  Ochestvo varchar(40) NOT NULL, 
  password bytea NOT NULL, 
  email    varchar(100) NOT NULL UNIQUE, 
  login    varchar(50) NOT NULL UNIQUE,  
  admin    bool, 
  PRIMARY KEY (Id_user));

CREATE TABLE Building (
  id_build      serial NOT NULL UNIQUE, 
  name_building varchar(10), 
  PRIMARY KEY (id_build));

CREATE TABLE Classrooms (
  number_class int4 NOT NULL, 
  id_build     int4 NOT NULL, 
  PRIMARY KEY (number_class, 
  id_build));

CREATE TABLE Department (
  id_dept   serial NOT NULL UNIQUE, 
  Dept_name varchar(40) NOT NULL UNIQUE, 
  PRIMARY KEY (id_dept));

CREATE TABLE Lessons (
  id_lesson    serial NOT NULL UNIQUE, 
  id_group     int4 NOT NULL, 
  id_teacher   int4 NOT NULL, 
  para         int2 NOT NULL, 
  id_subject   int4 NOT NULL,  
  type_lesson  varchar(20), 
  number_class int4 NOT NULL, 
  id_build     int4 NOT NULL, 
  start_date   date NOT NULL, 
  end_date     date NOT NULL, 
  frequency    int4 NOT NULL,  
  CONSTRAINT id_lesson 
    PRIMARY KEY (id_lesson));

CREATE TABLE st_Groups (
  id_group    serial NOT NULL UNIQUE, 
  title_group varchar(20) NOT NULL UNIQUE, 
  id_dept     int4, 
  PRIMARY KEY (id_group));

CREATE TABLE Students (
  Id_student  serial NOT NULL UNIQUE, 
  id_group    int4 NOT NULL, 
  Name        varchar(50) NOT NULL, 
  Surname     varchar(50) NOT NULL, 
  Ochestvo    varchar(50) NOT NULL, 
  PRIMARY KEY (Id_student));

CREATE TABLE Subjects (
  id_subject   serial NOT NULL UNIQUE, 
  name_subject varchar(40) NOT NULL UNIQUE, 
  PRIMARY KEY (id_subject));

CREATE TABLE Teachers (
  Id_teacher serial NOT NULL UNIQUE, 
  Name       varchar(40) NOT NULL, 
  Surname    varchar(50) NOT NULL, 
  Ochestvo   varchar(50) NOT NULL, 
  PRIMARY KEY (Id_teacher));

ALTER TABLE Students ADD CONSTRAINT r_1 FOREIGN KEY (id_group) REFERENCES st_Groups (id_group);
ALTER TABLE Lessons ADD CONSTRAINT r_2 FOREIGN KEY (id_group) REFERENCES st_Groups (id_group);
ALTER TABLE Lessons ADD CONSTRAINT r_3 FOREIGN KEY (id_subject) REFERENCES Subjects (id_subject);
ALTER TABLE Lessons ADD CONSTRAINT r_4 FOREIGN KEY (id_teacher) REFERENCES Teachers (Id_teacher);
ALTER TABLE st_Groups ADD CONSTRAINT r_5 FOREIGN KEY (id_dept) REFERENCES Department (id_dept);
ALTER TABLE Lessons ADD CONSTRAINT r_6 FOREIGN KEY (number_class, id_build) REFERENCES Classrooms (number_class, id_build);
ALTER TABLE Classrooms ADD CONSTRAINT r_7 FOREIGN KEY (id_build) REFERENCES Building (id_build);

CREATE OR REPLACE FUNCTION fmod (
   dividend double precision,
   divisor double precision
) RETURNS double precision
    LANGUAGE sql IMMUTABLE AS
'SELECT dividend - floor(dividend / divisor) * divisor';

CREATE OR REPLACE FUNCTION GET_CUR_LESSON( start_date in date, curdate in date, end_date in date ,frequency in int4 ) 
RETURNS int4 as 
$$
DECLARE
	v_r int4;
BEGIN 
  IF  fmod((curdate - start_date)::float /7, frequency) = 0 and curdate <= end_date
  then 
    V_R := 1;
  ELSE
    V_R := 0;
  END IF;
  return v_r;
END;
$$
LANGUAGE 'plpgsql';

--- Триггер для проверки, чтоб для одной группы на одно и тоже время не было 2 пары
CREATE OR REPLACE FUNCTION chack_lasson() returns trigger as 
$$
declare
c integer;
begin

if NEW.start_date > NEW.end_date then
  RAISE EXCEPTION 'Дата начала должна быть меньше даты окончания!';
end if;

select count(*) into c from Lessons l 
	where GET_CUR_LESSON(l.start_date, NEW.start_date, l.end_date, l.frequency) = 1 
	and l.para = NEW.para
	and l.id_group = NEW.id_group;

if c > 0 then
	RAISE EXCEPTION 'Пара в это время уже назначена!';
  
end if;
return NEW;
end
$$ LANGUAGE plpgsql;

create trigger chak_l before 
insert or update on lessons 
for each row execute procedure chack_lasson();
---

insert into all_user(surname,name,ochestvo,login, password, admin, email) 
       values ('admin', 'admin', 'admin','admin' , sha256('12345'), true, 'admin@admin.com');

--Department
insert into Department(dept_name) values('ЕЛІТ');  -- 1    
insert into Department(dept_name) values('ТЕСЕТ'); -- 2    
insert into Department(dept_name) values('ІФСК');  -- 3   
      
--Building
insert into building(name_building) values('ЕТ'); -- 1   
insert into building(name_building) values('М');  -- 2       
insert into building(name_building) values('Н');  -- 3  

--Classrooms 
insert into classrooms(id_build, number_class) values(1, 100);
insert into classrooms(id_build, number_class) values(1, 101);
insert into classrooms(id_build, number_class) values(1, 102);
insert into classrooms(id_build, number_class) values(1, 103);
insert into classrooms(id_build, number_class) values(1, 104);
insert into classrooms(id_build, number_class) values(1, 105);
insert into classrooms(id_build, number_class) values(1, 106);
insert into classrooms(id_build, number_class) values(1, 107);
insert into classrooms(id_build, number_class) values(1, 108);
insert into classrooms(id_build, number_class) values(1, 109);
insert into classrooms(id_build, number_class) values(1, 110);

insert into classrooms(id_build, number_class) values(2, 100);
insert into classrooms(id_build, number_class) values(2, 101);
insert into classrooms(id_build, number_class) values(2, 102);
insert into classrooms(id_build, number_class) values(2, 103);
insert into classrooms(id_build, number_class) values(2, 104);
insert into classrooms(id_build, number_class) values(2, 105);
insert into classrooms(id_build, number_class) values(2, 106);
insert into classrooms(id_build, number_class) values(2, 107);
insert into classrooms(id_build, number_class) values(2, 108);
insert into classrooms(id_build, number_class) values(2, 109);
insert into classrooms(id_build, number_class) values(2, 110);

insert into classrooms(id_build, number_class) values(3, 100);
insert into classrooms(id_build, number_class) values(3, 101);
insert into classrooms(id_build, number_class) values(3, 102);
insert into classrooms(id_build, number_class) values(3, 103);
insert into classrooms(id_build, number_class) values(3, 104);
insert into classrooms(id_build, number_class) values(3, 105);
insert into classrooms(id_build, number_class) values(3, 106);
insert into classrooms(id_build, number_class) values(3, 107);
insert into classrooms(id_build, number_class) values(3, 108);
insert into classrooms(id_build, number_class) values(3, 109);
insert into classrooms(id_build, number_class) values(3, 110);
--
--st_Groups 
insert into st_groups(title_group, id_dept) values('КБ-61',1);
insert into st_groups(title_group, id_dept) values('ІМ-81',2);  
insert into st_groups(title_group, id_dept) values('ЖТ-71',3); 

--students
insert into students(id_group, surname, name, ochestvo) 
  values(1, 'Борисенко', 'Николай' , 'Максимович');
insert into students(id_group, surname, name, ochestvo) 
  values(1, 'Стусенко', 'Сергей' , 'Вадимович');
insert into students(id_group, surname, name, ochestvo) 
  values(1, 'Огеенко', 'Светлана' , 'Владимировна');
insert into students(id_group, surname, name, ochestvo) 
  values(2, 'Цимбалюк', 'Яна' , 'Миколаївна');
insert into students(id_group, surname, name, ochestvo) 
  values(2, 'Ткаченко', 'Ирина' , 'Анатоліївна');
insert into students(id_group, surname, name, ochestvo) 
  values(2, 'Морозко', 'Ирина' , 'Степанівна');

--Subjects 
insert into subjects(name_subject) values('WEB-безопасность');                       -- 1                        
insert into subjects(name_subject) values('JAVA');                              -- 2                               
insert into subjects(name_subject) values('C++');                               -- 3                                
insert into subjects(name_subject) values('C#');                                -- 4                                 
insert into subjects(name_subject) values('Операционные системы');                -- 5                 
insert into subjects(name_subject) values('LINUX');                             -- 6                              
insert into subjects(name_subject) values('Бази данных');                        -- 7                         
insert into subjects(name_subject) values('Стеганография');                     -- 8                      
insert into subjects(name_subject) values('Дискретная математика');              -- 9               
insert into subjects(name_subject) values('Высшая математика');                   -- 10                    
insert into subjects(name_subject) values('Криптография');                      -- 11                       
insert into subjects(name_subject) values('Английский язык');                   -- 12                    
insert into subjects(name_subject) values('Обслуживание ПК');                 -- 13                  
insert into subjects(name_subject) values('ТСПП');                              -- 14                               
insert into subjects(name_subject) values('Численные методы');                    -- 15                     
insert into subjects(name_subject) values('Мат. логика');                       -- 16                        
insert into subjects(name_subject) values('Телекоммуникации');                   -- 17                    
insert into subjects(name_subject) values('Теория алгоритмов');                 -- 18                  
insert into subjects(name_subject) values('Мат. методы');                       -- 19                        
insert into subjects(name_subject) values('Забеспечение качественной инф.');         -- 20          
insert into subjects(name_subject) values('Информационная техника');                 -- 21          
insert into subjects(name_subject) values('Свойства материалов');            -- 22         
insert into subjects(name_subject) values('Основы электротехники');             -- 23         
insert into subjects(name_subject) values('Охрана труда');                     -- 24         
insert into subjects(name_subject) values('Экономика предприятий');             -- 25         
insert into subjects(name_subject) values('Исследование операций');              -- 26         
insert into subjects(name_subject) values('Случайные процессы');                 -- 27         
insert into subjects(name_subject) values('Методы многомерной статистики');  -- 28 
insert into subjects(name_subject) values('Теория управления');                  -- 29                   
insert into subjects(name_subject) values('Уравнения математической физики');          -- 30              
insert into subjects(name_subject) values('Теория вероятности и математическая статистика');     -- 31      
insert into subjects(name_subject) values('Теория функций действительной переменной');      -- 32       
insert into subjects(name_subject) values('Методы научных вычислений');         -- 33              
insert into subjects(name_subject) values('История');                           -- 34                            
insert into subjects(name_subject) values('Русский язык');                         -- 35                          
insert into subjects(name_subject) values('Методы журналистов');                -- 36                 
insert into subjects(name_subject) values('Основы журналистики');               -- 37                
insert into subjects(name_subject) values('Современный медиатекст');               -- 38                
insert into subjects(name_subject) values('История журналистики');              -- 39               
insert into subjects(name_subject) values('Русский язык СМИ');                      -- 40                       
insert into subjects(name_subject) values('Профессиональная этика и медиаправо');    -- 41         
insert into subjects(name_subject) values('Детали машин');                      -- 42 
insert into subjects(name_subject) values('Взаимозаменяемость, стандартизация и технические измерения');     -- 43 
insert into subjects(name_subject) values('Теория вероятности');          -- 44 
insert into subjects(name_subject) values('Физическое воспитание');                 -- 45 
insert into subjects(name_subject) values('Экономический анализ');                -- 46 
insert into subjects(name_subject) values('Экономика труда');                   -- 47 
insert into subjects(name_subject) values('Информационные системы в экономике');            -- 48 
insert into subjects(name_subject) values('Деловой иностранный язык');              -- 49 
insert into subjects(name_subject) values('Економетрика');                      -- 50 
insert into subjects(name_subject) values('Теория');                    -- 51 
insert into subjects(name_subject) values('Проектирование и конструирование');                -- 52 
insert into subjects(name_subject) values('Бизнес решения');                    -- 53 
insert into subjects(name_subject) values('Организация инновационной деятельности');              -- 54 
insert into subjects(name_subject) values('Start-UP');                          -- 55 
insert into subjects(name_subject) values('Планирование и бюджетирование');    -- 56 
insert into subjects(name_subject) values('Основы сценического искусства');      -- 57 
insert into subjects(name_subject) values('Менеджмент событий');                  -- 58 
insert into subjects(name_subject) values('Энтопсихология');                    -- 59 
insert into subjects(name_subject) values('История искусства');                 -- 60 
insert into subjects(name_subject) values('Имиджелогия и брендинг');           -- 61 
insert into subjects(name_subject) values('Региональные практики социально-культурных');    -- 62 

--Teachers
insert into Teachers(surname, name, ochestvo)        -- 1  
  values('Драгун', 'Надежда', 'Николаевна');
insert into Teachers(surname, name, ochestvo)        -- 2  
  values('Витвицький', 'Всеволод', 'Златович');  
insert into Teachers(surname, name, ochestvo)        -- 3   
  values('Довгаль', 'Галина', 'Богуславовна');
insert into Teachers(surname, name, ochestvo)        -- 4
  values('Куновський', 'Виктор', 'Соломонович');
insert into Teachers(surname, name, ochestvo)        -- 5
  values('Чуприн', 'Матвей', 'Иванович');
insert into Teachers(surname, name, ochestvo)        -- 6
  values('Андрусевич', 'Ника', 'Гордиславовна');
insert into Teachers(surname, name, ochestvo)        -- 7
  values('Авратинская', 'Шанетта', 'Тарасовна');
insert into Teachers(surname, name, ochestvo)        -- 8
  values('Штанько', 'Еммануил', 'Милославович');
insert into Teachers(surname, name, ochestvo)        -- 9
  values('Шаблой', 'Зореслава', 'Артуровна');
insert into Teachers(surname, name, ochestvo)        -- 10
  values('Слипченко', 'Чесмила', 'Леонидовна');
insert into Teachers(surname, name, ochestvo)        -- 11
  values('Трух', 'Юхим', 'Жданович');
insert into Teachers(surname, name, ochestvo)        -- 12
  values('Юрчишин', 'Еремей', 'Юхимович');
insert into Teachers(surname, name, ochestvo)        -- 13
  values('Смолич', 'Арина', 'Александровна');
insert into Teachers(surname, name, ochestvo)        -- 14
  values('Мацко', 'Шарлота', 'Максимовна');
insert into Teachers(surname, name, ochestvo)        -- 15
  values('Пилипчук', 'Чеслава', 'Федоровна');
insert into Teachers(surname, name, ochestvo)        -- 16
  values('Бернацкая', 'Огняна', 'Давидовна');
insert into Teachers(surname, name, ochestvo)        -- 17
  values('Арсенич', 'Йоган', 'Янович');
insert into Teachers(surname, name, ochestvo)        -- 18
  values('Пасенюк', 'Иван', 'Макарович');

--Lessons 
--Пары для КБ-61
insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    1,                 -- преподаватель
    14,                -- предмет
    1,                 -- номер пары
    'Лекция',          -- тип занятия
    3,                 -- корпус 
    101,               -- номер аудитории
    CURRENT_DATE - 27, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    2,                 -- преподаватель
    1,                 -- предмет
    2,                 -- номер пары
    'Практика',          -- тип занятия
    3,                 -- корпус 
    104,               -- номер аудитории
    CURRENT_DATE - 27, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

  insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    3,                 -- преподаватель
    12,                -- предмет
    3,                 -- номер пары
    'Практика',        -- тип занятия
    3,                 -- корпус 
    106,               -- номер аудитории
    CURRENT_DATE - 27, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    3,                 -- преподаватель
    12,                -- предмет
    3,                 -- номер пары
    'Лекция',        -- тип занятия
    1,                 -- корпус 
    107,               -- номер аудитории
    CURRENT_DATE - 26, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    3,                 -- преподаватель
    24,                -- предмет
    4,                 -- номер пары
    'Лекция',        -- тип занятия
    2,                 -- корпус 
    105,               -- номер аудитории
    CURRENT_DATE - 26, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    5,                 -- преподаватель
    7,                 -- предмет
    1,                 -- номер пары
    'Практика',        -- тип занятия
    3,                 -- корпус 
    101,               -- номер аудитории
    CURRENT_DATE - 26, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    5,                 -- преподаватель
    7,                 -- предмет
    2,                 -- номер пары
    'Лекция',        -- тип занятия
    2,                 -- корпус 
    104,               -- номер аудитории
    CURRENT_DATE - 26, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    7,                 -- преподаватель
    11,                 -- предмет
    1,                 -- номер пары
    'Практика',        -- тип занятия
    2,                 -- корпус 
    102,               -- номер аудитории
    CURRENT_DATE - 25, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    7,                 -- преподаватель
    11,                -- предмет
    2,                 -- номер пары
    'Лекция',          -- тип занятия
    2,                 -- корпус 
    102,               -- номер аудитории
    CURRENT_DATE - 25, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    1,                 -- преподаватель
    6,                 -- предмет
    3,                 -- номер пары
    'Практика',        -- тип занятия
    2,                 -- корпус 
    102,               -- номер аудитории
    CURRENT_DATE - 25, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    1,                 -- преподаватель
    6,                -- предмет
    1,                 -- номер пары
    'Лекция',          -- тип занятия
    2,                 -- корпус 
    102,               -- номер аудитории
    CURRENT_DATE - 24, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    9,                 -- преподаватель
    8,                 -- предмет
    2,                 -- номер пары
    'Лекция',          -- тип занятия
    1,                 -- корпус 
    101,               -- номер аудитории
    CURRENT_DATE - 24, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    9,                 -- преподаватель
    8,                 -- предмет
    1,                 -- номер пары
    'Практика',        -- тип занятия
    3,                 -- корпус 
    109,               -- номер аудитории
    CURRENT_DATE - 23, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    9,                 -- преподаватель
    8,                 -- предмет
    2,                 -- номер пары
    'Практика',        -- тип занятия
    3,                 -- корпус 
    109,               -- номер аудитории
    CURRENT_DATE - 23, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    10,                -- преподаватель
    12,                -- предмет
    3,                 -- номер пары
    'Лекция',        -- тип занятия
    2,                 -- корпус 
    109,               -- номер аудитории
    CURRENT_DATE - 23, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    9,                 -- преподаватель
    8,                 -- предмет
    1,                 -- номер пары
    'Практика',        -- тип занятия
    3,                 -- корпус 
    109,               -- номер аудитории
    CURRENT_DATE - 22, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    10,                -- преподаватель
    12,                -- предмет
    3,                 -- номер пары
    'Лекция',        -- тип занятия
    2,                 -- корпус 
    109,               -- номер аудитории
    CURRENT_DATE - 22, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    1,                 -- преподаватель
    6,                -- предмет
    1,                 -- номер пары
    'Лекция',          -- тип занятия
    2,                 -- корпус 
    102,               -- номер аудитории
    CURRENT_DATE - 21, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    9,                 -- преподаватель
    8,                 -- предмет
    2,                 -- номер пары
    'Лекция',          -- тип занятия
    1,                 -- корпус 
    101,               -- номер аудитории
    CURRENT_DATE - 21, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

insert into
  Lessons(
    id_group,
    id_teacher,
    id_subject,
    para,
    type_lesson,
    id_build,
    number_class,
    start_date,
    end_date,
    frequency
  )
values(
    1,                 -- группа
    9,                 -- преподаватель
    8,                 -- предмет
    3,                 -- номер пары
    'Практика',        -- тип занятия
    3,                 -- корпус 
    109,               -- номер аудитории
    CURRENT_DATE - 21, -- дата начала предмета
    CURRENT_DATE + 60, -- дата окончания предмета
    1                  -- повторение
  );

--Lessons 
--Пары для ІМ-61
