--
-- PostgreSQL database dump
--

-- Dumped from database version 10.9 (Ubuntu 10.9-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 11.2

-- Started on 2019-06-29 17:27:31

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16948)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 3058 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 220 (class 1255 OID 16944)
-- Name: fn_checkpassword(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_checkpassword(uname text, pass text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $_$
DECLARE passed BOOLEAN;
BEGIN
		SELECT (u_password = $2) INTO passed
		FROM users
		WHERE u_username = $1;
		
		RETURN passed;
END;
$_$;


ALTER FUNCTION public.fn_checkpassword(uname text, pass text) OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 16989)
-- Name: fn_checksessionid(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_checksessionid(sessionid uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $_$
DECLARE passed BOOLEAN;
BEGIN
		SELECT	CASE	
					WHEN	COUNT(S.session_id)	>0	THEN	TRUE
					WHEN	COUNT(S.session_id)	=0	THEN	FALSE
				END		AS	PASSED	INTO	passed
		FROM	PUBLIC.sessions AS S
		WHERE	S.session_id = $1;
		
		return passed;
END;
$_$;


ALTER FUNCTION public.fn_checksessionid(sessionid uuid) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16981)
-- Name: fn_createsessionid(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_createsessionid(uname text) RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $_$
DECLARE sessionId VARCHAR;
BEGIN
		INSERT INTO public.sessions(u_id) VALUES((SELECT u_id FROM public.users WHERE u_username = $1));
		
		SELECT session_id INTO sessionId
		FROM public.sessions
		WHERE u_id = (SELECT u_id FROM public.users WHERE u_username = $1);
		
		RETURN sessionId;
END;
$_$;


ALTER FUNCTION public.fn_createsessionid(uname text) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 16939)
-- Name: fn_createuser(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_createuser(uname text, email text, pass text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $_$
DECLARE done BOOLEAN;
BEGIN
		INSERT INTO users(u_username, u_email, u_password) VALUES($1, $2, $3);
		SELECT ($1 = $1) INTO done;
		
		RETURN done;
END;
$_$;


ALTER FUNCTION public.fn_createuser(uname text, email text, pass text) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 16990)
-- Name: fn_getuser(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getuser(sessionid uuid) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $_$
DECLARE uId INT;
BEGIN
		SELECT u_id INTO uId
		FROM public.sessions
		WHERE session_id = $1;
		
		RETURN uId;
END;
$_$;


ALTER FUNCTION public.fn_getuser(sessionid uuid) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 204 (class 1259 OID 16794)
-- Name: auth_group; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO roadmapuser;

--
-- TOC entry 203 (class 1259 OID 16792)
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3059 (class 0 OID 0)
-- Dependencies: 203
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- TOC entry 206 (class 1259 OID 16804)
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO roadmapuser;

--
-- TOC entry 205 (class 1259 OID 16802)
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3060 (class 0 OID 0)
-- Dependencies: 205
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- TOC entry 202 (class 1259 OID 16786)
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO roadmapuser;

--
-- TOC entry 201 (class 1259 OID 16784)
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3061 (class 0 OID 0)
-- Dependencies: 201
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- TOC entry 208 (class 1259 OID 16812)
-- Name: auth_user; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO roadmapuser;

--
-- TOC entry 210 (class 1259 OID 16822)
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO roadmapuser;

--
-- TOC entry 209 (class 1259 OID 16820)
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.auth_user_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_groups_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3062 (class 0 OID 0)
-- Dependencies: 209
-- Name: auth_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.auth_user_groups_id_seq OWNED BY public.auth_user_groups.id;


--
-- TOC entry 207 (class 1259 OID 16810)
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.auth_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3063 (class 0 OID 0)
-- Dependencies: 207
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.auth_user_id_seq OWNED BY public.auth_user.id;


--
-- TOC entry 212 (class 1259 OID 16830)
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO roadmapuser;

--
-- TOC entry 211 (class 1259 OID 16828)
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.auth_user_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_permissions_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3064 (class 0 OID 0)
-- Dependencies: 211
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.auth_user_user_permissions_id_seq OWNED BY public.auth_user_user_permissions.id;


--
-- TOC entry 214 (class 1259 OID 16890)
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO roadmapuser;

--
-- TOC entry 213 (class 1259 OID 16888)
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3065 (class 0 OID 0)
-- Dependencies: 213
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- TOC entry 200 (class 1259 OID 16776)
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO roadmapuser;

--
-- TOC entry 199 (class 1259 OID 16774)
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3066 (class 0 OID 0)
-- Dependencies: 199
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- TOC entry 198 (class 1259 OID 16765)
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO roadmapuser;

--
-- TOC entry 197 (class 1259 OID 16763)
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: roadmapuser
--

CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO roadmapuser;

--
-- TOC entry 3067 (class 0 OID 0)
-- Dependencies: 197
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: roadmapuser
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- TOC entry 215 (class 1259 OID 16918)
-- Name: django_session; Type: TABLE; Schema: public; Owner: roadmapuser
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO roadmapuser;

--
-- TOC entry 218 (class 1259 OID 16967)
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    session_id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    u_id integer,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_connection timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16930)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    u_id integer NOT NULL,
    u_username character varying(20) NOT NULL,
    u_email character varying(50) NOT NULL,
    u_password character varying(150) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16928)
-- Name: users_u_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.users ALTER COLUMN u_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_u_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 2835 (class 2604 OID 16797)
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- TOC entry 2836 (class 2604 OID 16807)
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- TOC entry 2834 (class 2604 OID 16789)
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- TOC entry 2837 (class 2604 OID 16815)
-- Name: auth_user id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_id_seq'::regclass);


--
-- TOC entry 2838 (class 2604 OID 16825)
-- Name: auth_user_groups id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_groups ALTER COLUMN id SET DEFAULT nextval('public.auth_user_groups_id_seq'::regclass);


--
-- TOC entry 2839 (class 2604 OID 16833)
-- Name: auth_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_permissions_id_seq'::regclass);


--
-- TOC entry 2840 (class 2604 OID 16893)
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- TOC entry 2833 (class 2604 OID 16779)
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- TOC entry 2832 (class 2604 OID 16768)
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- TOC entry 3038 (class 0 OID 16794)
-- Dependencies: 204
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- TOC entry 3040 (class 0 OID 16804)
-- Dependencies: 206
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- TOC entry 3036 (class 0 OID 16786)
-- Dependencies: 202
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	2	add_permission
6	Can change permission	2	change_permission
7	Can delete permission	2	delete_permission
8	Can view permission	2	view_permission
9	Can add group	3	add_group
10	Can change group	3	change_group
11	Can delete group	3	delete_group
12	Can view group	3	view_group
13	Can add user	4	add_user
14	Can change user	4	change_user
15	Can delete user	4	delete_user
16	Can view user	4	view_user
17	Can add content type	5	add_contenttype
18	Can change content type	5	change_contenttype
19	Can delete content type	5	delete_contenttype
20	Can view content type	5	view_contenttype
21	Can add session	6	add_session
22	Can change session	6	change_session
23	Can delete session	6	delete_session
24	Can view session	6	view_session
\.


--
-- TOC entry 3042 (class 0 OID 16812)
-- Dependencies: 208
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
\.


--
-- TOC entry 3044 (class 0 OID 16822)
-- Dependencies: 210
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- TOC entry 3046 (class 0 OID 16830)
-- Dependencies: 212
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- TOC entry 3048 (class 0 OID 16890)
-- Dependencies: 214
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- TOC entry 3034 (class 0 OID 16776)
-- Dependencies: 200
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	permission
3	auth	group
4	auth	user
5	contenttypes	contenttype
6	sessions	session
\.


--
-- TOC entry 3032 (class 0 OID 16765)
-- Dependencies: 198
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2019-06-27 10:26:37.473985+00
2	auth	0001_initial	2019-06-27 10:26:37.740691+00
3	admin	0001_initial	2019-06-27 10:26:37.81755+00
4	admin	0002_logentry_remove_auto_add	2019-06-27 10:26:37.83786+00
5	admin	0003_logentry_add_action_flag_choices	2019-06-27 10:26:37.858253+00
6	contenttypes	0002_remove_content_type_name	2019-06-27 10:26:37.900513+00
7	auth	0002_alter_permission_name_max_length	2019-06-27 10:26:37.922318+00
8	auth	0003_alter_user_email_max_length	2019-06-27 10:26:37.947329+00
9	auth	0004_alter_user_username_opts	2019-06-27 10:26:37.968226+00
10	auth	0005_alter_user_last_login_null	2019-06-27 10:26:38.000392+00
11	auth	0006_require_contenttypes_0002	2019-06-27 10:26:38.011606+00
12	auth	0007_alter_validators_add_error_messages	2019-06-27 10:26:38.025967+00
13	auth	0008_alter_user_username_max_length	2019-06-27 10:26:38.05452+00
14	auth	0009_alter_user_last_name_max_length	2019-06-27 10:26:38.078548+00
15	sessions	0001_initial	2019-06-27 10:26:38.123647+00
\.


--
-- TOC entry 3049 (class 0 OID 16918)
-- Dependencies: 215
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: roadmapuser
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
\.


--
-- TOC entry 3052 (class 0 OID 16967)
-- Dependencies: 218
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (session_id, u_id, created, last_connection) FROM stdin;
1db74476-99e6-11e9-b693-00155d013328	8	2019-06-28 20:48:43.15426+00	2019-06-28 20:48:43.15426+00
b9a5ed18-9a6f-11e9-b693-00155d013328	9	2019-06-29 13:13:45.816647+00	2019-06-29 13:13:45.816647+00
\.


--
-- TOC entry 3051 (class 0 OID 16930)
-- Dependencies: 217
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (u_id, u_username, u_email, u_password) FROM stdin;
8	augu1352	augustemmeryfunch@gmail.com	123456hj
9	sdcsds	zdsveafawf@gmail.com	ght
\.


--
-- TOC entry 3068 (class 0 OID 0)
-- Dependencies: 203
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 205
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 201
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 24, true);


--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 209
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 1, false);


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 207
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 1, false);


--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 211
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 1, false);


--
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 213
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 199
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 6, true);


--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 197
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: roadmapuser
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 15, true);


--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 216
-- Name: users_u_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_u_id_seq', 9, true);


--
-- TOC entry 2858 (class 2606 OID 16801)
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- TOC entry 2863 (class 2606 OID 16856)
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- TOC entry 2866 (class 2606 OID 16809)
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 2860 (class 2606 OID 16799)
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- TOC entry 2853 (class 2606 OID 16842)
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- TOC entry 2855 (class 2606 OID 16791)
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 2874 (class 2606 OID 16827)
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 2877 (class 2606 OID 16871)
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- TOC entry 2868 (class 2606 OID 16817)
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- TOC entry 2880 (class 2606 OID 16835)
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- TOC entry 2883 (class 2606 OID 16885)
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- TOC entry 2871 (class 2606 OID 16913)
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- TOC entry 2886 (class 2606 OID 16899)
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- TOC entry 2848 (class 2606 OID 16783)
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- TOC entry 2850 (class 2606 OID 16781)
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- TOC entry 2846 (class 2606 OID 16773)
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 2890 (class 2606 OID 16925)
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- TOC entry 2899 (class 2606 OID 16974)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (session_id);


--
-- TOC entry 2893 (class 2606 OID 16934)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (u_id);


--
-- TOC entry 2895 (class 2606 OID 16938)
-- Name: users users_u_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_u_email_key UNIQUE (u_email);


--
-- TOC entry 2897 (class 2606 OID 16936)
-- Name: users users_u_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_u_username_key UNIQUE (u_username);


--
-- TOC entry 2856 (class 1259 OID 16844)
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- TOC entry 2861 (class 1259 OID 16857)
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- TOC entry 2864 (class 1259 OID 16858)
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- TOC entry 2851 (class 1259 OID 16843)
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- TOC entry 2872 (class 1259 OID 16873)
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- TOC entry 2875 (class 1259 OID 16872)
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- TOC entry 2878 (class 1259 OID 16887)
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- TOC entry 2881 (class 1259 OID 16886)
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- TOC entry 2869 (class 1259 OID 16914)
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- TOC entry 2884 (class 1259 OID 16910)
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- TOC entry 2887 (class 1259 OID 16911)
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- TOC entry 2888 (class 1259 OID 16927)
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- TOC entry 2891 (class 1259 OID 16926)
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: roadmapuser
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- TOC entry 2902 (class 2606 OID 16850)
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2901 (class 2606 OID 16845)
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2900 (class 2606 OID 16836)
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2904 (class 2606 OID 16865)
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2903 (class 2606 OID 16860)
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2906 (class 2606 OID 16879)
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2905 (class 2606 OID 16874)
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2907 (class 2606 OID 16900)
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2908 (class 2606 OID 16905)
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: roadmapuser
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 2909 (class 2606 OID 16975)
-- Name: sessions sessions_u_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_u_id_fkey FOREIGN KEY (u_id) REFERENCES public.users(u_id);


-- Completed on 2019-06-29 17:27:31

--
-- PostgreSQL database dump complete
--

