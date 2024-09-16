-- This query to migrate the existing data to new table

-- Inserting all usernames data from both initial tables to users table.
INSERT INTO "users" ("username")
SELECT DISTINCT "username"
FROM (SELECT "username" FROM "bad_posts"
      UNION
      SELECT "username" FROM "bad_comments"
      UNION
      SELECT regexp_split_to_table(upvotes, ',')
      FROM "bad_posts" WHERE upvotes IS NOT NULL
      UNION
      SELECT regexp_split_to_table(downvotes, ',')
      FROM "bad_posts" WHERE downvotes IS NOT NULL
     )AS unique_usernames;

-- Inserting all topic & user_id from bad_posts table into topics table
INSERT INTO "topics" ("user_id", "topic_name")
SELECT DISTINCT ON (topic) u.id, bp.topic
FROM "bad_posts" AS bp
JOIN "users" AS u ON u.username = bp.username;

-- Inserting data into table posts
INSERT INTO "posts" ("id", "topic_id", "user_id", "title", "url", "post_content")
SELECT bp.id, t.id, u.id, LEFT(bp.title,100), bp.url, bp.text_content
FROM "bad_posts" AS bp
JOIN "topics" AS t ON bp.topic = t.topic_name
JOIN "users" AS u ON bp.username = u.username;

-- Inserting data into table comments
INSERT INTO "comments" ("user_id", "topic_id", "post_id", "comment")
SELECT u.id, p.topic_id, p.id, bc.text_content
FROM "bad_comments" AS bc
JOIN "users" AS u ON bc.username = u.username
JOIN "posts" AS p ON bc.post_id = p.id;

-- Inserting upvote data from bad_posts to table votes
WITH bp_upvote AS (SELECT id, regexp_split_to_table(upvotes, ',') AS upvoter_username FROM bad_posts)
INSERT INTO "votes" ("user_id", "post_id", "vote")
SELECT u.id, bpu.id, 1 AS vote
FROM bp_upvote AS bpu
JOIN "users" AS u ON u.username = bpu.upvoter_username;

-- Inserting downvote data from bad_posts to table votes
WITH bp_downvote AS (SELECT id, regexp_split_to_table(downvotes, ',') AS downvoter_username FROM bad_posts)
INSERT INTO "votes" ("user_id", "post_id", "vote")
SELECT u.id, bpd.id, -1 AS vote
FROM "bp_downvote" AS bpd
JOIN "users" AS u ON u.username = bpd.downvoter_username;
