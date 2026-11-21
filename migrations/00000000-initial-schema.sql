-- JM Services: complete schema for a NEW, EMPTY production database.
-- Run it once, before the first start of the backend (NODE_ENV=production disables TypeORM synchronize).
-- It already contains every migration up to 20261119-*: do NOT run the other files on a database created with it.
-- Generated from the entities (pg_dump --schema-only of a database built by synchronize).
-- Usage: psql "postgresql://USER:PASSWORD@HOST:5432/jmservices_db" -v ON_ERROR_STOP=1 -f migrations/00000000-initial-schema.sql

--
-- PostgreSQL database dump
--

\restrict G5G4lyQ6cdL2Oj59sClEtI2oNRQeSxGQgpMt6ObQVo3JEbdARodkskcpe8lC5p7

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: bookmakers_integration_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.bookmakers_integration_enum AS ENUM (
    'SERVCUL'
);


--
-- Name: discussions_statut_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.discussions_statut_enum AS ENUM (
    'depot',
    'retrait',
    'autre'
);


--
-- Name: discussions_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.discussions_type_enum AS ENUM (
    'depot_retrait',
    'support',
    'forum'
);


--
-- Name: message_reactions_typeemoji_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.message_reactions_typeemoji_enum AS ENUM (
    '👍',
    '❤️',
    '😂',
    '🔥',
    '😮'
);


--
-- Name: messages_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.messages_type_enum AS ENUM (
    'text',
    'image',
    'audio',
    'sticker'
);


--
-- Name: sms_attribution_origin; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sms_attribution_origin AS ENUM (
    'AUTO_MATI_PAY',
    'JM_SERVICES',
    'MANUEL'
);


--
-- Name: sms_capture_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sms_capture_status AS ENUM (
    'ATTRIBUE',
    'SANS_TRANSACTION',
    'A_RAPPROCHER',
    'IGNORE'
);


--
-- Name: transactions_methodevalidation_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transactions_methodevalidation_enum AS ENUM (
    'AUTO_NOTIFICATION',
    'ADMIN_MANUEL'
);


--
-- Name: transactions_statut_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transactions_statut_enum AS ENUM (
    'EN_ATTENTE_AUTO',
    'EN_VERIFICATION',
    'EN_ATTENTE_PREUVE',
    'EN_ATTENTE_ADMIN',
    'EN_RECLAMATION',
    'VALIDEE',
    'REJETEE',
    'ANNULEE'
);


--
-- Name: transactions_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transactions_type_enum AS ENUM (
    'DEPOT',
    'RETRAIT'
);


--
-- Name: users_role_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.users_role_enum AS ENUM (
    'USER',
    'ADMIN'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_capture_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_capture_devices (
    id integer NOT NULL,
    admin_id integer NOT NULL,
    device_id character varying(160) NOT NULL,
    last_heartbeat_at timestamp without time zone NOT NULL,
    consecutive_healthy_signals integer DEFAULT 0 NOT NULL,
    failure_reason character varying(80)
);


--
-- Name: admin_capture_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_capture_devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_capture_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_capture_devices_id_seq OWNED BY public.admin_capture_devices.id;


--
-- Name: admin_capture_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_capture_state (
    id smallint DEFAULT '1'::smallint NOT NULL,
    manual_override boolean DEFAULT false NOT NULL,
    outage_started_at timestamp without time zone,
    paused_expiration_ms bigint DEFAULT '0'::bigint NOT NULL,
    last_reminder_at timestamp without time zone,
    last_reported_available boolean DEFAULT false NOT NULL
);


--
-- Name: app_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_notifications (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    title character varying(100) NOT NULL,
    body character varying(500) NOT NULL,
    image_url text,
    user_id integer NOT NULL
);


--
-- Name: app_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_notifications_id_seq OWNED BY public.app_notifications.id;


--
-- Name: bannieres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bannieres (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    titre character varying NOT NULL,
    "sousTitre" character varying,
    image character varying,
    "texteCta" character varying,
    lien character varying,
    ordre integer DEFAULT 0 NOT NULL
);


--
-- Name: bannieres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bannieres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bannieres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bannieres_id_seq OWNED BY public.bannieres.id;


--
-- Name: bookmakers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookmakers (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    code character varying(30) NOT NULL,
    nom character varying(100) NOT NULL,
    image_url character varying(255),
    integration public.bookmakers_integration_enum,
    active boolean DEFAULT true NOT NULL,
    ordre integer DEFAULT 0 NOT NULL
);


--
-- Name: bookmakers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookmakers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookmakers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookmakers_id_seq OWNED BY public.bookmakers.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    libelle character varying NOT NULL,
    description character varying
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: discussion_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discussion_participants (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    "joinedAt" timestamp without time zone NOT NULL,
    "isAdmin" boolean DEFAULT false NOT NULL,
    "userId" integer,
    "discussionId" integer
);


--
-- Name: discussion_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.discussion_participants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.discussion_participants_id_seq OWNED BY public.discussion_participants.id;


--
-- Name: discussions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discussions (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    titre character varying NOT NULL,
    type public.discussions_type_enum NOT NULL,
    statut public.discussions_statut_enum DEFAULT 'autre'::public.discussions_statut_enum NOT NULL,
    active boolean DEFAULT true NOT NULL,
    image character varying,
    last_message_at timestamp without time zone DEFAULT now() NOT NULL,
    "lastMessageContent" character varying
);


--
-- Name: discussions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.discussions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.discussions_id_seq OWNED BY public.discussions.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    titre character varying NOT NULL,
    description character varying NOT NULL,
    "coverImage" character varying,
    "dateDebut" timestamp without time zone NOT NULL,
    "dateFin" timestamp without time zone NOT NULL,
    lieu character varying,
    "userId" integer,
    categorie_id integer NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: message_reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_reactions (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    "typeEmoji" public.message_reactions_typeemoji_enum NOT NULL,
    "userId" integer,
    "messageId" integer
);


--
-- Name: message_reactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_reactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_reactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_reactions_id_seq OWNED BY public.message_reactions.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    contenu character varying NOT NULL,
    type public.messages_type_enum DEFAULT 'text'::public.messages_type_enum NOT NULL,
    lu boolean DEFAULT false NOT NULL,
    "dateLu" timestamp without time zone,
    "isEdited" boolean DEFAULT false NOT NULL,
    "editedAt" timestamp without time zone,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp without time zone,
    epingle boolean DEFAULT false NOT NULL,
    "dateEnvoi" timestamp without time zone,
    image character varying,
    "senderId" integer,
    "discussionId" integer,
    "parentId" integer
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: operateurs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.operateurs (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    nom character varying NOT NULL,
    format_ussd character varying NOT NULL,
    format_retrait_ussd character varying(255),
    notification_name character varying(100),
    notification_title_admin character varying(150),
    notification_package_client character varying(150),
    notification_pattern_client text,
    notification_package_admin character varying(150),
    notification_pattern_admin text,
    image_url character varying,
    active boolean DEFAULT true NOT NULL
);


--
-- Name: operateurs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.operateurs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operateurs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.operateurs_id_seq OWNED BY public.operateurs.id;


--
-- Name: parametres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parametres (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    code character varying NOT NULL,
    libelle character varying NOT NULL,
    valeur double precision NOT NULL,
    valeur_texte text
);


--
-- Name: parametres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parametres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parametres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parametres_id_seq OWNED BY public.parametres.id;


--
-- Name: push_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_devices (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id integer NOT NULL,
    token text NOT NULL,
    platform character varying(20) NOT NULL,
    device_id character varying(255),
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: sms_capture_device_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sms_capture_device_tokens (
    id integer NOT NULL,
    admin_id integer NOT NULL,
    device_id character varying(160) NOT NULL,
    token_hash character varying(64) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    last_used_at timestamp without time zone,
    revoked_at timestamp without time zone
);


--
-- Name: sms_capture_device_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sms_capture_device_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sms_capture_device_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sms_capture_device_tokens_id_seq OWNED BY public.sms_capture_device_tokens.id;


--
-- Name: sms_captures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sms_captures (
    "trackingId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    fingerprint character varying(64) NOT NULL,
    device_id character varying(160) NOT NULL,
    expediteur character varying(160) NOT NULL,
    corps text NOT NULL,
    received_at timestamp without time zone NOT NULL,
    operateur character varying(100),
    montant integer,
    telephone character varying(40),
    reference character varying(160),
    statut public.sms_capture_status NOT NULL,
    origine_attribution public.sms_attribution_origin,
    motif text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    transaction_id uuid,
    attribue_par_id integer
);


--
-- Name: stickers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stickers (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    libelle character varying NOT NULL,
    code character varying NOT NULL,
    image character varying
);


--
-- Name: stickers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stickers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stickers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stickers_id_seq OWNED BY public.stickers.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    "trackingId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type public.transactions_type_enum NOT NULL,
    statut public.transactions_statut_enum DEFAULT 'EN_ATTENTE_AUTO'::public.transactions_statut_enum NOT NULL,
    montant integer NOT NULL,
    bookmaker character varying(30) DEFAULT '1XBET'::character varying NOT NULL,
    operateur character varying(100),
    "numeroTelephone" character varying(30),
    "compteDestinataire" character varying(100),
    code_retrait character varying(255),
    discussion_tracking_id character varying(100) NOT NULL,
    reference_client character varying(150),
    notification_brute_client text,
    "referencePaiement" character varying(150),
    "notificationBrute" text,
    "methodeValidation" public.transactions_methodevalidation_enum,
    "preuveFichier" character varying(255),
    "motifRejet" text,
    credit_error text,
    date_reclamation timestamp without time zone,
    date_traitement_reclamation timestamp without time zone,
    capture_pause_ms_at_creation bigint DEFAULT '0'::bigint NOT NULL,
    capture_reconciliation_required boolean DEFAULT false NOT NULL,
    "dateValidation" timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL,
    validated_by_id integer
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    "trackingId" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying(100),
    updated_by character varying(100),
    nom character varying NOT NULL,
    prenom character varying NOT NULL,
    username character varying NOT NULL,
    email character varying,
    password character varying,
    telephone character varying,
    image character varying,
    role public.users_role_enum DEFAULT 'USER'::public.users_role_enum NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "googleId" character varying,
    "appleId" character varying,
    provider character varying,
    "expoPushToken" character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: admin_capture_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_capture_devices ALTER COLUMN id SET DEFAULT nextval('public.admin_capture_devices_id_seq'::regclass);


--
-- Name: app_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_notifications ALTER COLUMN id SET DEFAULT nextval('public.app_notifications_id_seq'::regclass);


--
-- Name: bannieres id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bannieres ALTER COLUMN id SET DEFAULT nextval('public.bannieres_id_seq'::regclass);


--
-- Name: bookmakers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmakers ALTER COLUMN id SET DEFAULT nextval('public.bookmakers_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: discussion_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_participants ALTER COLUMN id SET DEFAULT nextval('public.discussion_participants_id_seq'::regclass);


--
-- Name: discussions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussions ALTER COLUMN id SET DEFAULT nextval('public.discussions_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: message_reactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_reactions ALTER COLUMN id SET DEFAULT nextval('public.message_reactions_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: operateurs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operateurs ALTER COLUMN id SET DEFAULT nextval('public.operateurs_id_seq'::regclass);


--
-- Name: parametres id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parametres ALTER COLUMN id SET DEFAULT nextval('public.parametres_id_seq'::regclass);


--
-- Name: sms_capture_device_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_capture_device_tokens ALTER COLUMN id SET DEFAULT nextval('public.sms_capture_device_tokens_id_seq'::regclass);


--
-- Name: stickers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stickers ALTER COLUMN id SET DEFAULT nextval('public.stickers_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: sms_capture_device_tokens PK_0bc6fd8a307165e3b755c4e669c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_capture_device_tokens
    ADD CONSTRAINT "PK_0bc6fd8a307165e3b755c4e669c" PRIMARY KEY (id);


--
-- Name: messages PK_18325f38ae6de43878487eff986; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "PK_18325f38ae6de43878487eff986" PRIMARY KEY (id);


--
-- Name: categories PK_24dbc6126a28ff948da33e97d3b; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "PK_24dbc6126a28ff948da33e97d3b" PRIMARY KEY (id);


--
-- Name: admin_capture_state PK_3c29e5355235f24cd443c909edc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_capture_state
    ADD CONSTRAINT "PK_3c29e5355235f24cd443c909edc" PRIMARY KEY (id);


--
-- Name: events PK_40731c7151fe4be3116e45ddf73; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "PK_40731c7151fe4be3116e45ddf73" PRIMARY KEY (id);


--
-- Name: push_devices PK_46b68decfd1164e1a796f48dc4a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_devices
    ADD CONSTRAINT "PK_46b68decfd1164e1a796f48dc4a" PRIMARY KEY (id);


--
-- Name: discussions PK_4b3d110d8e5d9077ddc0a0d1b4c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussions
    ADD CONSTRAINT "PK_4b3d110d8e5d9077ddc0a0d1b4c" PRIMARY KEY (id);


--
-- Name: app_notifications PK_4ff08fe3c2ebf2593490403bbe0; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_notifications
    ADD CONSTRAINT "PK_4ff08fe3c2ebf2593490403bbe0" PRIMARY KEY (id);


--
-- Name: message_reactions PK_654a9f0059ff93a8f156be66a5b; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT "PK_654a9f0059ff93a8f156be66a5b" PRIMARY KEY (id);


--
-- Name: discussion_participants PK_78b7fed424bcc36d7277bba6962; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_participants
    ADD CONSTRAINT "PK_78b7fed424bcc36d7277bba6962" PRIMARY KEY (id);


--
-- Name: sms_captures PK_7ee48c5e55f4aac2c4ba8cd8968; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_captures
    ADD CONSTRAINT "PK_7ee48c5e55f4aac2c4ba8cd8968" PRIMARY KEY ("trackingId");


--
-- Name: parametres PK_a0fe17264637cc7d62331dad21f; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parametres
    ADD CONSTRAINT "PK_a0fe17264637cc7d62331dad21f" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: admin_capture_devices PK_b9e7c74d328d62672e2fea2d8e4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_capture_devices
    ADD CONSTRAINT "PK_b9e7c74d328d62672e2fea2d8e4" PRIMARY KEY (id);


--
-- Name: bannieres PK_c6ff40aafa1a8367d5079237406; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bannieres
    ADD CONSTRAINT "PK_c6ff40aafa1a8367d5079237406" PRIMARY KEY (id);


--
-- Name: stickers PK_e1dafa4063a5532645cc2810374; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stickers
    ADD CONSTRAINT "PK_e1dafa4063a5532645cc2810374" PRIMARY KEY (id);


--
-- Name: transactions PK_ea767d0c00047273a2e6e5440cd; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT "PK_ea767d0c00047273a2e6e5440cd" PRIMARY KEY ("trackingId");


--
-- Name: operateurs PK_ee1c35a2e01b4bd7a0e4589ec9c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operateurs
    ADD CONSTRAINT "PK_ee1c35a2e01b4bd7a0e4589ec9c" PRIMARY KEY (id);


--
-- Name: bookmakers PK_f75b6ecebd5c6a9df57492e0b3a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmakers
    ADD CONSTRAINT "PK_f75b6ecebd5c6a9df57492e0b3a" PRIMARY KEY (id);


--
-- Name: discussions UQ_0189f9754a4e48923e24f7edd10; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussions
    ADD CONSTRAINT "UQ_0189f9754a4e48923e24f7edd10" UNIQUE ("trackingId");


--
-- Name: app_notifications UQ_0fb1c482492258f7d08de8699f8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_notifications
    ADD CONSTRAINT "UQ_0fb1c482492258f7d08de8699f8" UNIQUE ("trackingId");


--
-- Name: stickers UQ_1e6c0a7608eee696c4b800241ac; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stickers
    ADD CONSTRAINT "UQ_1e6c0a7608eee696c4b800241ac" UNIQUE (code);


--
-- Name: messages UQ_21a5de37af26188932bf0f83305; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "UQ_21a5de37af26188932bf0f83305" UNIQUE ("trackingId");


--
-- Name: users UQ_2fbaea68166a62835ac8dee2bc8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_2fbaea68166a62835ac8dee2bc8" UNIQUE ("trackingId");


--
-- Name: message_reactions UQ_3ab99136f355e164c80aa585e29; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT "UQ_3ab99136f355e164c80aa585e29" UNIQUE ("trackingId");


--
-- Name: operateurs UQ_4517cb8aee5934f97553daca8b5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.operateurs
    ADD CONSTRAINT "UQ_4517cb8aee5934f97553daca8b5" UNIQUE ("trackingId");


--
-- Name: categories UQ_4906f8a564903d9814484f78f37; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "UQ_4906f8a564903d9814484f78f37" UNIQUE ("trackingId");


--
-- Name: bannieres UQ_5569c971aaf1ceb90fb5834c9c4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bannieres
    ADD CONSTRAINT "UQ_5569c971aaf1ceb90fb5834c9c4" UNIQUE ("trackingId");


--
-- Name: users UQ_60cea0d80c39eedaaaf5e21f175; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_60cea0d80c39eedaaaf5e21f175" UNIQUE ("appleId");


--
-- Name: discussion_participants UQ_8291dafb39f108dff1046663e3a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_participants
    ADD CONSTRAINT "UQ_8291dafb39f108dff1046663e3a" UNIQUE ("trackingId");


--
-- Name: sms_captures UQ_8ef7546a0c4b03d066dcd3f6a7c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_captures
    ADD CONSTRAINT "UQ_8ef7546a0c4b03d066dcd3f6a7c" UNIQUE (fingerprint);


--
-- Name: parametres UQ_9332211c24d5025c3d99c2077d0; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parametres
    ADD CONSTRAINT "UQ_9332211c24d5025c3d99c2077d0" UNIQUE ("trackingId");


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: stickers UQ_a1ddec73b9aa0be6ecc6687c03f; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stickers
    ADD CONSTRAINT "UQ_a1ddec73b9aa0be6ecc6687c03f" UNIQUE ("trackingId");


--
-- Name: events UQ_a71cb8525d8c35c4396e06e2312; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "UQ_a71cb8525d8c35c4396e06e2312" UNIQUE ("trackingId");


--
-- Name: message_reactions UQ_d35f71680dd89cd399d6eb54774; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT "UQ_d35f71680dd89cd399d6eb54774" UNIQUE ("messageId", "userId");


--
-- Name: bookmakers UQ_db837662dc77380ba69e058ceb5; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmakers
    ADD CONSTRAINT "UQ_db837662dc77380ba69e058ceb5" UNIQUE ("trackingId");


--
-- Name: parametres UQ_de4af0e0c2f89140abfe4e7ac9e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parametres
    ADD CONSTRAINT "UQ_de4af0e0c2f89140abfe4e7ac9e" UNIQUE (code);


--
-- Name: transactions UQ_f04feec447f69e710938e348d50; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT "UQ_f04feec447f69e710938e348d50" UNIQUE ("referencePaiement");


--
-- Name: bookmakers UQ_f19262c25891e9c7e79ab94d906; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmakers
    ADD CONSTRAINT "UQ_f19262c25891e9c7e79ab94d906" UNIQUE (code);


--
-- Name: push_devices UQ_f847e055cb2f1c758694dd9b480; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_devices
    ADD CONSTRAINT "UQ_f847e055cb2f1c758694dd9b480" UNIQUE (token);


--
-- Name: sms_capture_device_tokens UQ_fefe13355729fe93d76f7e89082; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_capture_device_tokens
    ADD CONSTRAINT "UQ_fefe13355729fe93d76f7e89082" UNIQUE (token_hash);


--
-- Name: uq_admin_capture_device; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_admin_capture_device ON public.admin_capture_devices USING btree (admin_id, device_id);


--
-- Name: events FK_02c0ed81769e62070e0c6975bf3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "FK_02c0ed81769e62070e0c6975bf3" FOREIGN KEY (categorie_id) REFERENCES public.categories(id);


--
-- Name: sms_captures FK_131c661fa1f30ac5c42fc7df227; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_captures
    ADD CONSTRAINT "FK_131c661fa1f30ac5c42fc7df227" FOREIGN KEY (transaction_id) REFERENCES public.transactions("trackingId") ON DELETE SET NULL;


--
-- Name: messages FK_2db9cf2b3ca111742793f6c37ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "FK_2db9cf2b3ca111742793f6c37ce" FOREIGN KEY ("senderId") REFERENCES public.users(id);


--
-- Name: messages FK_38276ab4e0f41b360ddc898cd60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "FK_38276ab4e0f41b360ddc898cd60" FOREIGN KEY ("discussionId") REFERENCES public.discussions(id) ON DELETE CASCADE;


--
-- Name: discussion_participants FK_4cb19975f5d96593d0f69c38b9a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_participants
    ADD CONSTRAINT "FK_4cb19975f5d96593d0f69c38b9a" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: message_reactions FK_7623d77216e8457a552490259e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT "FK_7623d77216e8457a552490259e0" FOREIGN KEY ("messageId") REFERENCES public.messages(id) ON DELETE CASCADE;


--
-- Name: sms_captures FK_7ce537086f158128b302e3c2286; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_captures
    ADD CONSTRAINT "FK_7ce537086f158128b302e3c2286" FOREIGN KEY (attribue_par_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: messages FK_7d473d0de3669832052cac98b98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "FK_7d473d0de3669832052cac98b98" FOREIGN KEY ("parentId") REFERENCES public.messages(id) ON DELETE SET NULL;


--
-- Name: push_devices FK_80fd9275e4f18bf43e5b7008a19; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_devices
    ADD CONSTRAINT "FK_80fd9275e4f18bf43e5b7008a19" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: message_reactions FK_82d59cb474d00eea46d7e192f28; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_reactions
    ADD CONSTRAINT "FK_82d59cb474d00eea46d7e192f28" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: discussion_participants FK_8775deca32048500a3411a6ff7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_participants
    ADD CONSTRAINT "FK_8775deca32048500a3411a6ff7a" FOREIGN KEY ("discussionId") REFERENCES public.discussions(id) ON DELETE CASCADE;


--
-- Name: app_notifications FK_8bcc01715bbea6fed4bc654cb93; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_notifications
    ADD CONSTRAINT "FK_8bcc01715bbea6fed4bc654cb93" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: events FK_9929fa8516afa13f87b41abb263; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "FK_9929fa8516afa13f87b41abb263" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: transactions FK_cb00ceff80bc442d55b36a1f714; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT "FK_cb00ceff80bc442d55b36a1f714" FOREIGN KEY (validated_by_id) REFERENCES public.users(id);


--
-- Name: transactions FK_e9acc6efa76de013e8c1553ed2b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT "FK_e9acc6efa76de013e8c1553ed2b" FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict G5G4lyQ6cdL2Oj59sClEtI2oNRQeSxGQgpMt6ObQVo3JEbdARodkskcpe8lC5p7

