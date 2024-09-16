-- 1.a Create Table users
CREATE TABLE "users"
(
    "id" SERIAL PRIMARY KEY,
    "username" VARCHAR(25) UNIQUE NOT NULL,
    "login_time" TIMESTAMP,

    CONSTRAINT "ck_username_cant_be_empty" CHECK (Length(Trim("username"))> 0)
);

-- 1.b Create Table topics
CREATE TABLE "topics"
(
    "id" SERIAL PRIMARY KEY,
    "user_id" INT,
    "topic_name" VARCHAR(30) UNIQUE NOT NULL,
    "description" VARCHAR(500),

    CONSTRAINT "ck_topics_cant_be_empty" CHECK (Length(Trim("topic_name"))> 0)
);

-- 1.c Create Table posts
CREATE TABLE "posts"
(
    "id" SERIAL PRIMARY KEY,
    "user_id" INT,
    "topic_id" INT NOT NULL,
    "title" VARCHAR(100) NOT NULL,
    "url" TEXT,
    "post_content" TEXT,
    "post_time" DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT "ck_posts_cant_be_empty" CHECK (Length(Trim("title")) > 0),
    CONSTRAINT "ck_text_or_URL" CHECK ((("url") IS NULL AND ("post_content") IS NOT NULL)
                                    OR (("url") IS NOT NULL AND ("post_content") IS NULL)),
    CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
    CONSTRAINT "fk_topic_id" FOREIGN KEY ("topic_id") REFERENCES "topics" ("id") ON DELETE CASCADE
);


-- 1.d Create Table comments
CREATE TABLE "comments"
(
     "id" SERIAL PRIMARY KEY,
    "user_id" INT,
    "parent_id" INT DEFAULT NULL,
    "topic_id" INT NOT NULL,
    "post_id" INT NOT NULL,
    "comment" TEXT NOT NULL,

    CONSTRAINT "ck_comment_cant_be_empty" CHECK (Length(Trim("comment"))> 0 ),
    CONSTRAINT "parent_comment_id" FOREIGN KEY ("parent_id") REFERENCES "comments"("id")ON DELETE CASCADE,
    CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
    CONSTRAINT "fk_topic_id" FOREIGN KEY ("topic_id") REFERENCES "topics" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_post_id" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE
);

-- 1.e Create Table votes
CREATE TABLE "votes"
(
    "id" SERIAL PRIMARY KEY,
    "user_id" INT,
    "post_id" INT NOT NULL,
    "vote" INT NOT NULL,
    CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
    CONSTRAINT "fk_post_id" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE,
    CONSTRAINT "votes_values" CHECK ("vote" = 1 OR "vote" = -1),
    CONSTRAINT "vote_once" UNIQUE ("user_id", "post_id")
);

-----------------------------------------------------------------------------------------------------------------------------
-- 2.a Create an INDEX to find all users who haven't logged in in the last year
CREATE INDEX "idx_login" ON "users" ("username", "login_time");

-- 2.f Create Index to list the latest posts for a given topic.
CREATE INDEX "idx_latest_post_by_topic" ON "posts" ("topic_id", "url", "post_content", "post_time");

-- 2.g Create an Index to list the latest posts made by a given user.
CREATE INDEX "idx_latest_post_by_user" ON "posts" ("user_id", "url", "post_content", "post_time");

-- 2.h Create an Index to find posts that link to specific URL.
CREATE INDEX "idx_posts_url" ON "posts" ("url");

-- 2.j Create an Index to list all the direct children of a parent comment
CREATE INDEX "idx_parent_id" ON "comments" ("parent_id");

-- 2.k Create an Index to list the latest comments made by a given user.
CREATE INDEX "idx_latest_comment_by_user" ON "comments" ("user_id", "comment");

-- 2.l Create an Index to find score of post votes.
CREATE INDEX "post_score" ON "votes" ("post_id", "vote");
