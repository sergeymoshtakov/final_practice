--Показать TOP-10 пользователей с самым высоким средним рейтингом анкеты (Anketa_Rate, AVG, средний рейтинг должен быть представлен в виде вещесвтенного числа).

SELECT TOP 10 u.user_id, u.nick, u.age, g.name, AVG(ar.rating) AS 'average rating'
FROM Dating.dbo.Users u RIGHT JOIN Dating.dbo.anketa_rate ar ON u.user_id = ar.id_kogo
JOIN Dating.dbo.gender g ON g.id = u.sex
GROUP BY u.user_id, u.nick, u.age, g.name
ORDER BY AVG(ar.rating) DESC

--Показать всех пользователей с высшим образованием, которые не курят, не пьют и не употребляют наркотики.
SELECT u.user_id, u.nick, u.age, g.name
FROM Dating.dbo.Users u JOIN Dating.dbo.education e ON e.id = u.id_education
JOIN Dating.dbo.drugs d ON d.id = u.my_drugs
JOIN Dating.dbo.smoking s ON s.id = u.my_smoke
JOIN Dating.dbo.drinking dr ON dr.id = u.my_drink
JOIN Dating.dbo.gender g ON g.id = u.sex
WHERE e.id = 4 AND d.id = 1 AND s.id = 1 AND dr.id = 1

--Сделать запрос, который позволит найти пользователей по указанным данным:
-- ник (не обязательно точный)
-- пол
-- минимальный возраст
-- максимальный возраст
-- минимальный рост
-- максимальный рост
-- минимальный вес
-- максимальный вес

SELECT u.user_id, u.nick, u.age, g.name
FROM Dating.dbo.users u JOIN Dating.dbo.gender g ON g.id = u.sex
WHERE u.nick LIKE '%а%' AND g.id = 1
AND u.age BETWEEN 14 AND 54
AND u.rost BETWEEN 0 AND 200
AND u.ves BETWEEN 0 AND 100

--Показать всех стройных голубоглазых блондинок, затем всех спортивных кареглазых брюнетов, а в конце их общее количество (UNION, одним запросом на SELECT).
SELECT COUNT (*)
FROM
(SELECT u.user_id, u.nick, u.age, g.name
FROM Dating.dbo.users u JOIN Dating.dbo.figure f ON u.my_build = f.id
JOIN Dating.dbo.eyescolor ec ON ec.id = u.eyes_color
JOIN Dating.dbo.haircolor hc ON hc.id = u.hair_color
JOIN Dating.dbo.gender g ON g.id = u.sex
WHERE f.id = 2 AND ec.id = 4 AND hc.id = 1 AND g.id = 2
UNION
SELECT u.user_id, u.nick, u.age, g.name
FROM Dating.dbo.users u JOIN Dating.dbo.figure f ON u.my_build = f.id
JOIN Dating.dbo.eyescolor ec ON ec.id = u.eyes_color
JOIN Dating.dbo.haircolor hc ON hc.id = u.hair_color
JOIN Dating.dbo.gender g ON g.id = u.sex
WHERE f.id = 4 AND ec.id = 2 AND hc.id = 4 AND g.id = 1) AS subquery

--Показать всех программистов с пирсингом, которые к тому же умеют вышивать крестиком (Moles, Framework и Interes)

SELECT u.user_id, u.nick, u.age, g.name
FROM Dating.dbo.users u JOIN Dating.dbo.users_interes ui ON u.user_id = ui.user_id
JOIN Dating.dbo.interes i ON i.id = ui.interes_id
JOIN Dating.dbo.users_moles um ON um.user_id = u.user_id
JOIN Dating.dbo.moles m ON m.id = um.moles_id
JOIN Dating.dbo.framework f ON f.id = u.id_framework
JOIN Dating.dbo.gender g ON g.id = u.sex
WHERE i.id = 23 AND m.id = 1 AND f.id = 1

--Показать сколько подарков подарили каждому пользователю, у которого знак зодиака Рыбы.

SELECT u.user_id, u.nick, u.age, g.name, COUNT(gi.id_to) AS 'quantity of presents'
FROM Dating.dbo.users u
JOIN Dating.dbo.goroskop gor ON gor.id = u.id_zodiak
JOIN Dating.dbo.gift_service gi ON gi.id_to = u.user_id
JOIN Dating.dbo.gender g ON g.id = u.sex
WHERE gor.id = 12
GROUP BY u.user_id, u.nick, u.age, g.name

--Показать как много зарабатывают себе на жизнь полиглоты (знающие более 5 языков), совершенно не умеющие готовить.
SELECT u.user_id, u.nick, u.age, g.name, r.name
FROM Dating.dbo.users u JOIN Dating.dbo.users_languages ul ON ul.user_id = u.user_id
JOIN Dating.dbo.languages l ON ul.languages_id = l.id
JOIN Dating.dbo.gender g ON g.id = u.sex
JOIN Dating.dbo.kitchen k ON k.id = u.like_kitchen
JOIN Dating.dbo.richness r ON r.id = u.my_rich
WHERE k.id = 2
GROUP BY u.user_id, u.nick, u.age, g.name, r.name
HAVING COUNT(l.id) > 5

--Показать всех буддистов, которые занимаются восточными единоборствами, живут на вокзале, и в свободное время катаются на скейте.
SELECT u.user_id, u.nick, u.age, g.name
FROM Dating.dbo.users u
JOIN Dating.dbo.religion re ON re.id = u.religion
JOIN Dating.dbo.users_sport us ON us.user_id = u.user_id
JOIN Dating.dbo.sport s ON s.id = us.sport_id
JOIN Dating.dbo.gender g ON g.id = u.sex
JOIN Dating.dbo.residence r ON r.id = u.my_home
WHERE re.id = 6 AND s.id = 9 AND r.id = 9 AND s.id = 9

--Показать возрастную аудиторию пользователей в виде:

--возраст	  кол-во    %
-- до 18	   2000	   40.0
-- 18-24	   1500	   30.0
-- 24-30	   1000	   20.0
-- от 30	    500	   10.0

SELECT 
  age_group AS 'возраст',
  SUM(count) AS 'кол-во',
  FORMAT(SUM(count) * 100.0 / (SELECT COUNT(*) FROM Dating.dbo.users), 'N1') + '%' AS '%'
FROM (
  SELECT 
    CASE 
      WHEN u.age < 18 THEN 'до 18'
      WHEN u.age BETWEEN 18 AND 24 THEN '18-24'
      WHEN u.age BETWEEN 25 AND 30 THEN '24-30'
      ELSE 'от 30'
    END AS age_group,
    1 AS count
  FROM Dating.dbo.users u
) grouped_data
GROUP BY age_group
ORDER BY 
  CASE 
    WHEN age_group = 'до 18' THEN 1
    WHEN age_group = '18-24' THEN 2
    WHEN age_group = '24-30' THEN 3
    ELSE 4
  END ASC

--Показать 5 самых популярных слов, отправленных в личных сообщениях, и то, как часто они встречаются.

SELECT TOP 5
    word,
    COUNT(*) AS word_count,
    FORMAT(COUNT(*) * 100.0 / total_words, 'N1') + '%' AS percentage
FROM (
    SELECT
        value AS word
    FROM STRING_SPLIT((SELECT STRING_AGG(m.mess, ' ') FROM Dating.dbo.messages m), ' ')
) words
CROSS JOIN (
    SELECT COUNT(*) AS total_words FROM STRING_SPLIT((SELECT STRING_AGG(m.mess, ' ') FROM Dating.dbo.messages m), ' ')
) total
WHERE LEN(word) > 0
GROUP BY word, total_words
ORDER BY word_count DESC;