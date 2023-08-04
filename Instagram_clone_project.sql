CREATE TABLE USERS (
id SERIAL PRIMARY KEY,
username VARCHAR(255) UNIQUE, 
created_at TIMESTAMP DEFAULT NOW() );

ALTER Table USERS 
ALTER column username SET not NULL ;

CREATE TABLE photos (
id SERIAL PRIMARY KEY,
image_url VARCHAR(255) NOT NULL,
user_id INT NOT NULL,
created_at TIMESTAMP DEFAULT NOW(),
FOREIGN KEY (user_id) REFERENCES USERS(id));

CREATE TABLE comments (
id SERIAL PRIMARY KEY,
comment_text VARCHAR(255)NOT NULL,
user_id INT NOT NULL,
photo_id INT NOT NULL,
created_at TIMESTAMP DEFAULT NOW(),
FOREIGN KEY (user_id) REFERENCES USERS(id),
FOREIGN KEY (photo_id) REFERENCES photos(id));

CREATE TABLE likes (
user_id INT NOT NULL,
photo_id INT NOT NULL,
created_at TIMESTAMP DEFAULT NOW(),
FOREIGN KEY (user_id) REFERENCES USERS(id),
FOREIGN KEY (photo_id) REFERENCES photos(id),
PRIMARY KEY(user_id, photo_id)
);

CREATE TABLE follows (
follower_id INT NOT NULL,
following_id INT NOT NULL,
created_at TIMESTAMP DEFAULT NOW(),
FOREIGN KEY (follower_id) REFERENCES USERS(id),
FOREIGN KEY (following_id) REFERENCES USERS(id),
PRIMARY KEY(follower_id, following_id)
);

CREATE TABLE tags (
id SERIAL PRIMARY KEY,
tag_name VARCHAR(255) UNIQUE,
created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE photo_tags (
photo_id INT NOT NULL,
tag_id INT NOT NULL,
FOREIGN KEY (photo_id) REFERENCES photos(id),
FOREIGN KEY (tag_id) REFERENCES tags (id),
PRIMARY KEY (photo_id, tag_id)
)

--1. Find 5 oldest users
SELECT * FROM USERS 
ORDER BY created_at desc LIMIT 5;

--2. What day of the week do most users register on ?
SELECT EXTRACT('DOW' FROM created_at) As day, count(*) as total
FROM users
group by day
ORDER BY total desc;

--3. Target inactive users who never posted a photo
SELECT username FROM users
LEFT JOIN photos 
	ON users.id = photos.user_id
WHERE photos.id IS NULL;

-- Most liked photo on insta
SELECT photos.id, photos.image_url, username ,COUNT(*) AS total
FROM photos
INNER JOIN likes  
ON photos.id = likes.photo_id
INNER JOIN users
ON users.id = photos.user_id
GROUP BY photos.id
ORDER BY total DESC
LIMIT 2;

SELECT
	username,
	image_url,
	COUNT(photo_id) AS likes
FROM likes
JOIN photos
	ON photos.id = likes.photo_id
JOIN users
	ON users.id = photos.user_id
GROUP BY photo_id
ORDER BY likes DESC
LIMIT 1;

--How many times the user posts
SELECT username,COUNT(photos.id) AS total FROM users
INNER JOIN photos
ON users.id = photos.user_id
GROUP BY username
ORDER BY total DESC;

--How many times the average user posts
SELECT
(
	(SELECT COUNT(*) FROM photos) /
	(SELECT COUNT(*) FROM users)
) AS avg_posts;

-- What are the (5) most used hashtags?
SELECT
	tag_name,
	COUNT(*) AS total
FROM tags
JOIN photo_tags
	ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC
LIMIT 5;

-- Find bots: users who have liked every photo
SELECT 
	username
FROM users
INNER JOIN likes
	ON users.id = likes.user_id
GROUP BY likes.user_id
HAVING COUNT(*) = (SELECT COUNT(*) FROM photos);