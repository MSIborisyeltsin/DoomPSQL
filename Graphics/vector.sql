CREATE TYPE Vector2i AS (
    x INT,
    y INT
);

CREATE FUNCTION vector2i_add(l Vector2i, r Vector2i) RETURNS Vector2i AS $$
    SELECT ROW(l.x + r.x, l.y + r.y)::Vector2i;
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION vector2i_sub(l Vector2i, r Vector2i) RETURNS Vector2i AS $$
    SELECT ROW(l.x - r.x, l.y - r.y)::Vector2i;
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION vector2i_eq(l Vector2i, r Vector2i) RETURNS BOOL AS $$
    SELECT l = r;
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION vector2i_neq(l Vector2i, r Vector2i) RETURNS BOOL AS $$
    SELECT l != r;
$$ LANGUAGE SQL IMMUTABLE;
