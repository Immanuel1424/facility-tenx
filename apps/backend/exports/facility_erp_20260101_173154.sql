--
-- PostgreSQL database dump
--

\restrict TW5an4XixA1hTgw8VGPOJ6blrYTDMcqa8S8D13hANWhr1xYtqQQmuZeApHkcnRX

-- Dumped from database version 14.20 (Homebrew)
-- Dumped by pg_dump version 14.20 (Homebrew)

-- Started on 2026-01-01 17:31:54 IST

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
-- TOC entry 2 (class 3079 OID 58365)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 4413 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 885 (class 1247 OID 58424)
-- Name: acl_entries_effect_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.acl_entries_effect_enum AS ENUM (
    'allow',
    'deny'
);


--
-- TOC entry 1029 (class 1247 OID 59714)
-- Name: audit_logs_action_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.audit_logs_action_enum AS ENUM (
    'CREATE',
    'READ',
    'UPDATE',
    'DELETE',
    'LOGIN',
    'LOGOUT',
    'LOGIN_FAILED',
    'ASSIGN',
    'STATUS_CHANGE',
    'EXPORT',
    'IMPORT',
    'PASSWORD_RESET',
    'PERMISSION_CHANGE',
    'ROLE_CHANGE'
);


--
-- TOC entry 1032 (class 1247 OID 59744)
-- Name: audit_logs_resource_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.audit_logs_resource_type_enum AS ENUM (
    'USER',
    'ROLE',
    'PERMISSION',
    'TICKET',
    'COMMENT',
    'ATTACHMENT',
    'CATEGORY',
    'DEPARTMENT',
    'SLA_CONFIG',
    'VILLA',
    'COMPANY',
    'SESSION',
    'NOTIFICATION'
);


--
-- TOC entry 1003 (class 1247 OID 59098)
-- Name: maintenance_tickets_priority_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.maintenance_tickets_priority_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT'
);


--
-- TOC entry 1000 (class 1247 OID 59080)
-- Name: maintenance_tickets_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.maintenance_tickets_status_enum AS ENUM (
    'NEW',
    'ACKNOWLEDGED',
    'ASSIGNED',
    'IN_PROGRESS',
    'ON_HOLD',
    'COMPLETED',
    'CLOSED',
    'CANCELLED'
);


--
-- TOC entry 1044 (class 1247 OID 64425)
-- Name: maintenance_tickets_ticket_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.maintenance_tickets_ticket_type_enum AS ENUM (
    'MAINTENANCE',
    'SERVICE_REQUEST',
    'INCIDENT',
    'INSPECTION',
    'PREVENTIVE',
    'COMPLAINT'
);


--
-- TOC entry 936 (class 1247 OID 58607)
-- Name: notification_audit_logs_severity_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notification_audit_logs_severity_enum AS ENUM (
    'info',
    'warning',
    'critical'
);


--
-- TOC entry 912 (class 1247 OID 58518)
-- Name: notification_deliveries_channel_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notification_deliveries_channel_enum AS ENUM (
    'in_app',
    'email',
    'sms',
    'whatsapp',
    'push'
);


--
-- TOC entry 915 (class 1247 OID 58530)
-- Name: notification_deliveries_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notification_deliveries_status_enum AS ENUM (
    'pending',
    'success',
    'failed',
    'retrying'
);


--
-- TOC entry 930 (class 1247 OID 58585)
-- Name: notification_templates_channel_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notification_templates_channel_enum AS ENUM (
    'in_app',
    'email',
    'sms',
    'whatsapp',
    'push'
);


--
-- TOC entry 924 (class 1247 OID 58560)
-- Name: notifications_channels_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notifications_channels_enum AS ENUM (
    'in_app',
    'email',
    'sms',
    'whatsapp',
    'push'
);


--
-- TOC entry 921 (class 1247 OID 58553)
-- Name: notifications_severity_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notifications_severity_enum AS ENUM (
    'info',
    'warning',
    'critical'
);


--
-- TOC entry 1014 (class 1247 OID 59596)
-- Name: sla_configurations_priority_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sla_configurations_priority_enum AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT'
);


--
-- TOC entry 1023 (class 1247 OID 59662)
-- Name: ticket_attachments_attachment_context_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_attachments_attachment_context_enum AS ENUM (
    'TICKET_CREATION',
    'WORK_PROGRESS',
    'COMPLETION',
    'COMMENT'
);


--
-- TOC entry 1020 (class 1247 OID 59650)
-- Name: ticket_attachments_attachment_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_attachments_attachment_type_enum AS ENUM (
    'IMAGE',
    'DOCUMENT',
    'VIDEO',
    'AUDIO',
    'OTHER'
);


--
-- TOC entry 1026 (class 1247 OID 59688)
-- Name: ticket_comments_comment_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_comments_comment_type_enum AS ENUM (
    'PUBLIC',
    'INTERNAL',
    'WORK_NOTE',
    'SYSTEM'
);


--
-- TOC entry 879 (class 1247 OID 62432)
-- Name: ticket_priority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_priority AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT'
);


--
-- TOC entry 1017 (class 1247 OID 59621)
-- Name: ticket_sla_sla_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_sla_sla_status_enum AS ENUM (
    'ON_TRACK',
    'AT_RISK',
    'BREACHED',
    'PAUSED',
    'MET'
);


--
-- TOC entry 876 (class 1247 OID 62414)
-- Name: ticket_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_status AS ENUM (
    'NEW',
    'ACKNOWLEDGED',
    'ASSIGNED',
    'IN_PROGRESS',
    'ON_HOLD',
    'COMPLETED',
    'CLOSED',
    'CANCELLED'
);


--
-- TOC entry 997 (class 1247 OID 59036)
-- Name: ticket_status_history_new_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_status_history_new_status_enum AS ENUM (
    'NEW',
    'ACKNOWLEDGED',
    'ASSIGNED',
    'IN_PROGRESS',
    'ON_HOLD',
    'COMPLETED',
    'CLOSED',
    'CANCELLED'
);


--
-- TOC entry 994 (class 1247 OID 59016)
-- Name: ticket_status_history_previous_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_status_history_previous_status_enum AS ENUM (
    'NEW',
    'ACKNOWLEDGED',
    'ASSIGNED',
    'IN_PROGRESS',
    'ON_HOLD',
    'COMPLETED',
    'CLOSED',
    'CANCELLED'
);


--
-- TOC entry 873 (class 1247 OID 62405)
-- Name: ticket_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ticket_type AS ENUM (
    'MAINTENANCE',
    'SERVICE_REQUEST',
    'INCIDENT',
    'INSPECTION'
);


--
-- TOC entry 894 (class 1247 OID 58450)
-- Name: users_authprovider_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.users_authprovider_enum AS ENUM (
    'local',
    'azure_ad',
    'okta',
    'auth0',
    'keycloak'
);


--
-- TOC entry 891 (class 1247 OID 58443)
-- Name: users_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.users_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended'
);


--
-- TOC entry 258 (class 1255 OID 66642)
-- Name: update_cities_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cities_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- TOC entry 259 (class 1255 OID 66644)
-- Name: update_locations_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_locations_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- TOC entry 256 (class 1255 OID 66380)
-- Name: update_modified_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_modified_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- TOC entry 4414 (class 0 OID 0)
-- Dependencies: 256
-- Name: FUNCTION update_modified_column(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_modified_column() IS 'Automatically updates updated_at column on row update. Must be used with BEFORE UPDATE trigger.';


--
-- TOC entry 260 (class 1255 OID 66678)
-- Name: update_user_devices_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_user_devices_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- TOC entry 257 (class 1255 OID 66606)
-- Name: update_villa_type_configs_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_villa_type_configs_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 65588)
-- Name: acl_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acl_entries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    resource_type character varying(100) NOT NULL,
    resource_id uuid,
    user_id uuid,
    permission_id uuid,
    effect public.acl_entries_effect_enum DEFAULT 'allow'::public.acl_entries_effect_enum NOT NULL,
    conditions jsonb
);


--
-- TOC entry 237 (class 1259 OID 65793)
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    user_id uuid,
    user_email character varying(255),
    action public.audit_logs_action_enum NOT NULL,
    resource_type public.audit_logs_resource_type_enum NOT NULL,
    resource_id uuid,
    resource_name character varying(255),
    description text,
    old_values jsonb,
    new_values jsonb,
    changed_fields jsonb,
    ip_address character varying(45),
    user_agent text,
    request_path character varying(255),
    request_method character varying(10),
    response_status integer,
    duration_ms integer,
    is_success boolean DEFAULT false NOT NULL,
    error_message text,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 243 (class 1259 OID 66608)
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    code character varying(10),
    emirate character varying(50),
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 4415 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE cities; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.cities IS 'Reference table for UAE cities. Used in address dropdowns.';


--
-- TOC entry 4416 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN cities.emirate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cities.emirate IS 'Emirate name (Dubai, Abu Dhabi, Sharjah, etc.)';


--
-- TOC entry 210 (class 1259 OID 65410)
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    logo_url character varying(255),
    timezone character varying(100),
    currency character varying(10),
    is_active boolean DEFAULT true NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 65648)
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 65808)
-- Name: hierarchy_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hierarchy_nodes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    type character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    "externalId" character varying(255),
    "parentId" uuid,
    metadata jsonb
);


--
-- TOC entry 236 (class 1259 OID 65778)
-- Name: holidays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.holidays (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(100) NOT NULL,
    holiday_date date NOT NULL,
    description text,
    is_recurring boolean DEFAULT false NOT NULL,
    applies_to_all_sites boolean DEFAULT true NOT NULL,
    site_ids uuid[],
    holiday_type character varying(50)
);


--
-- TOC entry 244 (class 1259 OID 66620)
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    city_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    code character varying(10),
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 4417 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE locations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.locations IS 'Reference table for locations/areas within cities. Used in address dropdowns.';


--
-- TOC entry 4418 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN locations.city_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.locations.city_id IS 'Foreign key to cities table';


--
-- TOC entry 232 (class 1259 OID 65703)
-- Name: maintenance_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance_tickets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    ticket_number character varying(50) NOT NULL,
    ticket_type public.maintenance_tickets_ticket_type_enum DEFAULT 'MAINTENANCE'::public.maintenance_tickets_ticket_type_enum NOT NULL,
    villa_id uuid,
    site_id uuid,
    space_id uuid,
    created_by uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    location_detail character varying(255),
    status public.maintenance_tickets_status_enum DEFAULT 'NEW'::public.maintenance_tickets_status_enum NOT NULL,
    priority public.maintenance_tickets_priority_enum DEFAULT 'MEDIUM'::public.maintenance_tickets_priority_enum NOT NULL,
    category_id uuid,
    contact_number character varying(50),
    alternate_contact character varying(50),
    preferred_time character varying(255),
    department_id uuid,
    assigned_supervisor_id uuid,
    supervisor_assigned_at timestamp with time zone,
    assigned_technician_id uuid,
    assigned_by uuid,
    assigned_at timestamp with time zone,
    acknowledged_by uuid,
    acknowledged_at timestamp with time zone,
    scheduled_at timestamp with time zone,
    technician_notes text,
    resolution_notes text,
    completed_at timestamp with time zone,
    closed_at timestamp with time zone,
    auto_close_at timestamp with time zone,
    tenant_confirmed boolean DEFAULT false NOT NULL,
    assigned_team_id uuid,
    parent_ticket_id uuid,
    is_escalated boolean DEFAULT false NOT NULL,
    escalation_level integer DEFAULT 0,
    escalated_at timestamp with time zone,
    villa_number character varying(50),
    priority_id uuid,
    rating integer,
    rating_comment text,
    rated_at timestamp with time zone,
    rated_by uuid,
    CONSTRAINT maintenance_tickets_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- TOC entry 4419 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN maintenance_tickets.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.maintenance_tickets.company_id IS 'Multi-tenant isolation: all tickets belong to a company';


--
-- TOC entry 4420 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN maintenance_tickets.villa_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.maintenance_tickets.villa_id IS 'Preferred: FK to villas table. Use instead of deprecated villa_number.';


--
-- TOC entry 4421 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN maintenance_tickets.villa_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.maintenance_tickets.villa_number IS 'DEPRECATED: Use villa_id instead. Kept for backward compatibility.';


--
-- TOC entry 218 (class 1259 OID 65517)
-- Name: notification_audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_audit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    "eventType" character varying(128) NOT NULL,
    severity public.notification_audit_logs_severity_enum NOT NULL,
    recipient_user_id uuid,
    event_payload jsonb,
    metadata jsonb
);


--
-- TOC entry 215 (class 1259 OID 65480)
-- Name: notification_deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_deliveries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    notification_id uuid NOT NULL,
    channel public.notification_deliveries_channel_enum NOT NULL,
    status public.notification_deliveries_status_enum DEFAULT 'pending'::public.notification_deliveries_status_enum NOT NULL,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_error text,
    "notificationId" uuid
);


--
-- TOC entry 217 (class 1259 OID 65506)
-- Name: notification_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_templates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code character varying(128) NOT NULL,
    channel public.notification_templates_channel_enum NOT NULL,
    subject character varying(255),
    body text NOT NULL,
    default_variables jsonb
);


--
-- TOC entry 216 (class 1259 OID 65493)
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    recipient_user_id uuid,
    type character varying(128) NOT NULL,
    severity public.notifications_severity_enum DEFAULT 'info'::public.notifications_severity_enum NOT NULL,
    title character varying(255),
    message text NOT NULL,
    payload jsonb,
    is_read boolean DEFAULT false NOT NULL,
    read_at timestamp with time zone,
    channels public.notifications_channels_enum[] NOT NULL
);


--
-- TOC entry 240 (class 1259 OID 66064)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id uuid NOT NULL,
    user_id uuid NOT NULL,
    email character varying(255) NOT NULL,
    otp character varying(6) NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used_at timestamp without time zone,
    attempts integer DEFAULT 0 NOT NULL,
    ip_address character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- TOC entry 4422 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE password_reset_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.password_reset_tokens IS 'Stores password reset tokens and OTPs for forgot password flow';


--
-- TOC entry 220 (class 1259 OID 65540)
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    resource character varying(100) NOT NULL,
    action character varying(50) NOT NULL,
    description text,
    category character varying(50),
    display_order integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 241 (class 1259 OID 66498)
-- Name: priority; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.priority (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id uuid NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    color_code text NOT NULL,
    icon_name text,
    display_order integer DEFAULT 0 NOT NULL,
    default_sla_hours integer,
    escalation_hours integer,
    is_active boolean DEFAULT true NOT NULL,
    is_system boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_priority_color_format CHECK ((color_code ~ '^#[0-9A-Fa-f]{6}$'::text))
);


--
-- TOC entry 4423 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.priority IS 'Priority levels with visual configuration (colors, icons) and business rules (SLA, escalation). Supports tenant-specific customization.';


--
-- TOC entry 4424 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN priority.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.priority.code IS 'Unique code per company (LOW, MEDIUM, HIGH, URGENT). Used for mapping from enum.';


--
-- TOC entry 4425 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN priority.color_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.priority.color_code IS 'Hex color code for UI display (e.g., #FF5722)';


--
-- TOC entry 4426 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN priority.icon_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.priority.icon_name IS 'Material Design icon name for UI display';


--
-- TOC entry 4427 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN priority.default_sla_hours; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.priority.default_sla_hours IS 'Default SLA time in hours for tickets with this priority';


--
-- TOC entry 4428 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN priority.escalation_hours; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.priority.escalation_hours IS 'Hours before auto-escalation for this priority';


--
-- TOC entry 4429 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN priority.is_system; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.priority.is_system IS 'System priorities cannot be deleted, only deactivated';


--
-- TOC entry 219 (class 1259 OID 65528)
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    "ipAddress" character varying(255),
    "userAgent" text,
    revoked_at timestamp without time zone
);


--
-- TOC entry 221 (class 1259 OID 65552)
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 65564)
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    hierarchy_level integer DEFAULT 0 NOT NULL,
    parent_role_id uuid
);


--
-- TOC entry 211 (class 1259 OID 65423)
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    company_id uuid,
    code character varying(20) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    address character varying(500),
    city character varying(100),
    country character varying(100),
    is_parent boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    parent_site_id uuid
);


--
-- TOC entry 4430 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN sites.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sites.company_id IS 'Multi-tenant isolation: all sites belong to a company';


--
-- TOC entry 234 (class 1259 OID 65745)
-- Name: sla_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sla_configurations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    priority public.sla_configurations_priority_enum NOT NULL,
    first_response_time_minutes integer NOT NULL,
    acknowledgement_time_minutes integer NOT NULL,
    resolution_time_minutes integer NOT NULL,
    escalation_level_1_minutes integer,
    escalation_level_2_minutes integer,
    escalation_level_3_minutes integer,
    apply_business_hours boolean DEFAULT true NOT NULL,
    business_start_time time without time zone,
    business_end_time time without time zone,
    working_days character varying(20),
    exclude_holidays boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_by_id uuid
);


--
-- TOC entry 212 (class 1259 OID 65437)
-- Name: space_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.space_categories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    code character varying(5) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL
);


--
-- TOC entry 213 (class 1259 OID 65451)
-- Name: spaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spaces (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    site_id uuid,
    space_category_id uuid,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    "siteId" uuid,
    "spaceCategoryId" uuid
);


--
-- TOC entry 4431 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN spaces.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.spaces.company_id IS 'Multi-tenant isolation: all spaces belong to a company';


--
-- TOC entry 230 (class 1259 OID 65675)
-- Name: team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_members (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    team_id uuid NOT NULL,
    user_id uuid NOT NULL,
    is_lead boolean DEFAULT false NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 231 (class 1259 OID 65689)
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    department_id uuid,
    lead_user_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    color_code character varying(7)
);


--
-- TOC entry 227 (class 1259 OID 65632)
-- Name: ticket_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_attachments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    ticket_id uuid NOT NULL,
    uploaded_by_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    original_name character varying(255) NOT NULL,
    mime_type character varying(100) NOT NULL,
    file_size integer NOT NULL,
    storage_path character varying(500) NOT NULL,
    storage_url character varying(1000),
    attachment_type public.ticket_attachments_attachment_type_enum DEFAULT 'OTHER'::public.ticket_attachments_attachment_type_enum NOT NULL,
    attachment_context public.ticket_attachments_attachment_context_enum DEFAULT 'TICKET_CREATION'::public.ticket_attachments_attachment_context_enum NOT NULL,
    description text,
    checksum character varying(64),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    comment_id uuid,
    image_width integer,
    image_height integer,
    thumbnail_url character varying(500)
);


--
-- TOC entry 229 (class 1259 OID 65660)
-- Name: ticket_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_categories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    parent_category_id uuid,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    icon character varying(50),
    color_code character varying(7),
    default_sla_hours integer,
    default_department_id uuid,
    created_by_id uuid
);


--
-- TOC entry 226 (class 1259 OID 65616)
-- Name: ticket_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_comments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    ticket_id uuid NOT NULL,
    created_by_id uuid NOT NULL,
    content text NOT NULL,
    comment_type public.ticket_comments_comment_type_enum DEFAULT 'PUBLIC'::public.ticket_comments_comment_type_enum NOT NULL,
    is_edited boolean DEFAULT false NOT NULL,
    edited_at timestamp with time zone,
    parent_comment_id uuid,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone
);


--
-- TOC entry 235 (class 1259 OID 65760)
-- Name: ticket_sla; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_sla (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    ticket_id uuid NOT NULL,
    sla_configuration_id uuid NOT NULL,
    first_response_deadline timestamp with time zone NOT NULL,
    response_deadline timestamp with time zone NOT NULL,
    resolution_deadline timestamp with time zone NOT NULL,
    first_response_at timestamp with time zone,
    acknowledged_at timestamp with time zone,
    resolved_at timestamp with time zone,
    sla_status public.ticket_sla_sla_status_enum DEFAULT 'ON_TRACK'::public.ticket_sla_sla_status_enum NOT NULL,
    first_response_breached boolean DEFAULT false NOT NULL,
    response_breached boolean DEFAULT false NOT NULL,
    resolution_breached boolean DEFAULT false NOT NULL,
    paused_at timestamp with time zone,
    total_paused_minutes integer DEFAULT 0 NOT NULL,
    current_escalation_level integer DEFAULT 0 NOT NULL,
    last_escalation_at timestamp with time zone,
    actual_response_minutes integer,
    actual_resolution_minutes integer
);


--
-- TOC entry 233 (class 1259 OID 65733)
-- Name: ticket_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_status_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    ticket_id uuid NOT NULL,
    previous_status public.ticket_status_history_previous_status_enum,
    new_status public.ticket_status_history_new_status_enum NOT NULL,
    changed_by uuid NOT NULL,
    notes text,
    metadata jsonb
);


--
-- TOC entry 245 (class 1259 OID 66655)
-- Name: user_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_devices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id uuid NOT NULL,
    user_id uuid NOT NULL,
    fcm_token text NOT NULL,
    platform character varying(20) NOT NULL,
    device_info jsonb,
    is_active boolean DEFAULT true,
    last_used_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_devices_platform_check CHECK (((platform)::text = ANY ((ARRAY['web'::character varying, 'android'::character varying, 'ios'::character varying])::text[])))
);


--
-- TOC entry 223 (class 1259 OID 65576)
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL
);


--
-- TOC entry 239 (class 1259 OID 66042)
-- Name: user_villas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_villas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id uuid NOT NULL,
    user_id uuid NOT NULL,
    villa_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- TOC entry 225 (class 1259 OID 65601)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    email character varying(255) NOT NULL,
    "passwordHash" character varying(255),
    "firstName" character varying(100),
    "lastName" character varying(100),
    department_id uuid,
    status public.users_status_enum DEFAULT 'active'::public.users_status_enum NOT NULL,
    "authProvider" public.users_authprovider_enum DEFAULT 'local'::public.users_authprovider_enum NOT NULL,
    external_id character varying(255),
    "providerMetadata" jsonb,
    last_login_at timestamp without time zone,
    phone_number character varying(20),
    alternate_phone_number character varying(20),
    lease_expiry_date timestamp with time zone,
    deleted_at timestamp without time zone,
    villa_number character varying(50),
    villa_numbers jsonb
);


--
-- TOC entry 4432 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN users.deleted_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.deleted_at IS 'Timestamp when user was soft-deleted. NULL means user is not deleted. Used to distinguish deleted users from inactive users.';


--
-- TOC entry 242 (class 1259 OID 66586)
-- Name: villa_type_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.villa_type_configs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id uuid NOT NULL,
    villa_type character varying(50) NOT NULL,
    display_name character varying(255),
    default_bedroom_count integer,
    default_floor_count integer,
    default_area_sqm numeric(10,2),
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 4433 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE villa_type_configs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.villa_type_configs IS 'Configurable defaults for villa types per company. Enables faster data entry by auto-filling bedroom count, floor count, and area based on villa type.';


--
-- TOC entry 4434 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN villa_type_configs.villa_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villa_type_configs.villa_type IS 'Villa type code (e.g., 1BHK, 2BHK, Studio, Duplex). Must be unique per company.';


--
-- TOC entry 4435 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN villa_type_configs.display_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villa_type_configs.display_name IS 'Optional display name for the villa type (e.g., "1 Bedroom Hall Kitchen").';


--
-- TOC entry 4436 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN villa_type_configs.default_bedroom_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villa_type_configs.default_bedroom_count IS 'Default bedroom count. Auto-filled when creating a villa with this type.';


--
-- TOC entry 4437 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN villa_type_configs.default_floor_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villa_type_configs.default_floor_count IS 'Default floor count. Auto-filled when creating a villa with this type.';


--
-- TOC entry 4438 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN villa_type_configs.default_area_sqm; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villa_type_configs.default_area_sqm IS 'Default area in square meters. Auto-filled when creating a villa with this type.';


--
-- TOC entry 4439 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN villa_type_configs.display_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villa_type_configs.display_order IS 'Display order for dropdowns/lists. Lower numbers appear first.';


--
-- TOC entry 4440 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN villa_type_configs.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villa_type_configs.is_active IS 'Whether this configuration is active. Inactive configs won''t appear in dropdowns.';


--
-- TOC entry 4441 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN villa_type_configs.metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villa_type_configs.metadata IS 'Additional metadata (JSONB). Can store custom fields like description, amenities, etc.';


--
-- TOC entry 214 (class 1259 OID 65464)
-- Name: villas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.villas (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    villa_code character varying(50),
    site_id uuid,
    space_id uuid,
    owner_name character varying(255),
    tenant_name character varying(255),
    contact_phone character varying(50),
    contact_email character varying(255),
    block character varying(50),
    street character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    is_occupied boolean DEFAULT true NOT NULL,
    floor_count integer,
    bedroom_count integer,
    area_sqm numeric(10,2),
    metadata jsonb,
    villa_type character varying(50),
    parking_slot_number character varying(50),
    meter_number character varying(50),
    water_meter_number character varying(50),
    remarks text,
    city character varying(100),
    pin_code character varying(20),
    villa_number character varying(50) NOT NULL,
    makani_number character varying(50),
    po_box character varying(50)
);


--
-- TOC entry 4442 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.company_id IS 'Multi-tenant isolation: all villas belong to a company';


--
-- TOC entry 4443 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.villa_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.villa_type IS 'Villa type (e.g., 1BHK, 2BK, 3BK, 4BK, Studio, Penthouse)';


--
-- TOC entry 4444 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.parking_slot_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.parking_slot_number IS 'Parking slot number assigned to the villa';


--
-- TOC entry 4445 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.meter_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.meter_number IS 'Electricity meter number';


--
-- TOC entry 4446 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.water_meter_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.water_meter_number IS 'Water meter number';


--
-- TOC entry 4447 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.remarks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.remarks IS 'Additional remarks or notes about the villa';


--
-- TOC entry 4448 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.city; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.city IS 'City name for the villa address';


--
-- TOC entry 4449 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.pin_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.pin_code IS 'Postal/PIN code for the villa address';


--
-- TOC entry 4450 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.makani_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.makani_number IS 'MAKANI number - UAE official addressing system unique location identifier';


--
-- TOC entry 4451 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN villas.po_box; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.villas.po_box IS 'P.O. Box number for postal delivery in UAE';


--
-- TOC entry 4386 (class 0 OID 65588)
-- Dependencies: 224
-- Data for Name: acl_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.acl_entries (id, company_id, created_at, updated_at, resource_type, resource_id, user_id, permission_id, effect, conditions) FROM stdin;
\.


--
-- TOC entry 4399 (class 0 OID 65793)
-- Dependencies: 237
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, company_id, user_id, user_email, action, resource_type, resource_id, resource_name, description, old_values, new_values, changed_fields, ip_address, user_agent, request_path, request_method, response_status, duration_ms, is_success, error_message, metadata, created_at) FROM stdin;
\.


--
-- TOC entry 4405 (class 0 OID 66608)
-- Dependencies: 243
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cities (id, name, code, emirate, display_order, is_active, created_at, updated_at) FROM stdin;
ed4d9e04-a259-4d49-8ccb-99533284cbaf	Dubai	DXB	Dubai	0	t	2025-12-30 12:27:38.855277+05:30	2025-12-30 12:27:38.855277+05:30
112013f0-50d7-4d06-89c6-ccdacd206e9c	Abu Dhabi	AUH	Abu Dhabi	1	t	2025-12-30 12:27:38.855277+05:30	2025-12-30 12:27:38.855277+05:30
8c680c52-3535-48e0-b6ec-7c05723d75d3	Sharjah	SHJ	Sharjah	2	t	2025-12-30 12:27:38.855277+05:30	2025-12-30 12:27:38.855277+05:30
f37a9d07-16bd-4495-8465-dad655c6de02	Ajman	AJM	Ajman	3	t	2025-12-30 12:27:38.855277+05:30	2025-12-30 12:27:38.855277+05:30
736c25e7-e0a5-4a5c-beed-5cfa07ea4623	Ras Al Khaimah	RAK	Ras Al Khaimah	4	t	2025-12-30 12:27:38.855277+05:30	2025-12-30 12:27:38.855277+05:30
f47ae43c-fb63-4fe4-a8bf-354beea962de	Fujairah	FJR	Fujairah	5	t	2025-12-30 12:27:38.855277+05:30	2025-12-30 12:27:38.855277+05:30
c163dfba-2d57-4791-ad58-948dcb651fec	Umm Al Quwain	UAQ	Umm Al Quwain	6	t	2025-12-30 12:27:38.855277+05:30	2025-12-30 12:27:38.855277+05:30
\.


--
-- TOC entry 4372 (class 0 OID 65410)
-- Dependencies: 210
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.companies (id, created_at, updated_at, code, name, description, logo_url, timezone, currency, is_active) FROM stdin;
eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-26 11:37:06.756141	ALOS	Villa Maintenance Company	\N	\N	\N	\N	t
\.


--
-- TOC entry 4390 (class 0 OID 65648)
-- Dependencies: 228
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, company_id, created_at, updated_at, name, description, is_active) FROM stdin;
e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	Plumbing	Plumbing and water systems	t
aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	Electrical	Electrical systems and repairs	t
9cb540b9-3bfc-4912-8293-293ff2a2c279	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	HVAC	Heating, ventilation, and air conditioning	t
5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	General Maintenance	General maintenance and repairs	t
e0d8cb45-3a1f-47b9-b1fb-ec0f317e4ed4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	Landscaping	Landscaping and outdoor maintenance	t
\.


--
-- TOC entry 4400 (class 0 OID 65808)
-- Dependencies: 238
-- Data for Name: hierarchy_nodes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hierarchy_nodes (id, company_id, created_at, updated_at, type, name, "externalId", "parentId", metadata) FROM stdin;
\.


--
-- TOC entry 4398 (class 0 OID 65778)
-- Dependencies: 236
-- Data for Name: holidays; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.holidays (id, company_id, created_at, updated_at, name, holiday_date, description, is_recurring, applies_to_all_sites, site_ids, holiday_type) FROM stdin;
\.


--
-- TOC entry 4406 (class 0 OID 66620)
-- Dependencies: 244
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.locations (id, city_id, name, code, display_order, is_active, created_at, updated_at) FROM stdin;
deec7419-52fb-42fb-b654-2944308917bf	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Downtown Dubai	DTD	0	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
f1877270-d4b0-4fc5-9eba-cf945e1f2ab8	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Dubai Marina	DMR	1	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
902a3ba0-a761-47c9-89c2-8a903b94b21d	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Jumeirah	JMR	2	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
1fb0f5ff-ba05-47b2-a199-b56d975ad536	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Business Bay	BSB	3	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
d350382e-52ba-4a7e-ab64-51354015e3a0	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Palm Jumeirah	PJM	4	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
80d346c5-35a1-48fc-9c8c-12361538647a	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Dubai Hills	DHH	5	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
7a1ed030-2521-49b2-bce8-d95565afc403	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Arabian Ranches	ARB	6	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
1e02090e-0eb8-420f-8e08-870ea2030a13	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Emirates Hills	EMH	7	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
735d71c2-6467-4096-b27d-52b4c38b9fbf	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Jumeirah Lakes Towers	JLT	8	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
6187bbce-3ca9-440f-b8df-61b168730a68	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Dubai Sports City	DSC	9	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
5373b9d5-c423-4dfc-9381-ad1b24c6a015	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Dubai Silicon Oasis	DSO	10	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
e72f3e5d-27dd-4182-9aaa-63714d7bdb18	ed4d9e04-a259-4d49-8ccb-99533284cbaf	International City	INC	11	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
0c5b1afd-3b57-4739-a30f-5e4ffc056669	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Dubai Land	DLD	12	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
b2e8e936-8a11-4476-b44a-fc3bf00c124c	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Al Barsha	ABS	13	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
114d498c-00e2-48f5-9d2d-b8c3191877ab	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Al Quoz	AQZ	14	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
12daa8fc-0b5a-4743-aec8-2486c9e4e41a	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Deira	DER	15	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
05c454c3-b579-4b92-885c-d2bfda786383	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Bur Dubai	BDB	16	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
352e145b-efb9-4f3a-90dd-d02815f82b3e	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Jebel Ali	JBA	17	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
558b124b-6b53-43be-ac1d-63219a685ca2	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Dubai Investment Park	DIP	18	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
2d6e28e1-8b90-4782-8918-756360cb0630	ed4d9e04-a259-4d49-8ccb-99533284cbaf	Motor City	MTC	19	t	2025-12-30 12:27:38.858109+05:30	2025-12-30 12:27:38.858109+05:30
76b8667c-1283-4bd2-a4ce-74c86adedc04	112013f0-50d7-4d06-89c6-ccdacd206e9c	Al Reem Island	ARI	0	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
61c3733c-8dd6-4e6a-bbbf-7844ac353276	112013f0-50d7-4d06-89c6-ccdacd206e9c	Yas Island	YAS	1	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
778e3a0d-bc32-47d1-badd-3caf1d65afd7	112013f0-50d7-4d06-89c6-ccdacd206e9c	Saadiyat Island	SDY	2	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
216dda1e-f539-47c8-bf6f-3ecf62a2b9a9	112013f0-50d7-4d06-89c6-ccdacd206e9c	Al Maryah Island	AMY	3	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
314db1a4-2743-451d-8754-4387f14993e8	112013f0-50d7-4d06-89c6-ccdacd206e9c	Corniche Area	CRN	4	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
d2b75ff2-00ab-48f4-8c13-54b0680d999f	112013f0-50d7-4d06-89c6-ccdacd206e9c	Al Khalidiyah	AKH	5	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
95eacc90-4d6e-4bce-bd1d-b23c875de79f	112013f0-50d7-4d06-89c6-ccdacd206e9c	Al Bateen	ABT	6	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
052be83e-4b7b-449d-a85b-38c943572cde	112013f0-50d7-4d06-89c6-ccdacd206e9c	Al Mushrif	AMF	7	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
26b71c16-738e-4693-ad35-9ca7a93f17eb	112013f0-50d7-4d06-89c6-ccdacd206e9c	Al Karamah	AKR	8	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
d6df0bc0-9560-4c6e-9104-684ab416fab7	112013f0-50d7-4d06-89c6-ccdacd206e9c	Al Nahyan	ANH	9	t	2025-12-30 12:27:38.862427+05:30	2025-12-30 12:27:38.862427+05:30
9ba76655-fea2-4cbd-82a8-64e04fbc66c1	8c680c52-3535-48e0-b6ec-7c05723d75d3	Al Qasimia	AQS	0	t	2025-12-30 12:27:38.863517+05:30	2025-12-30 12:27:38.863517+05:30
26dfd072-b7ce-40a3-bf04-8a9abed5f2a9	8c680c52-3535-48e0-b6ec-7c05723d75d3	Al Majaz	AMJ	1	t	2025-12-30 12:27:38.863517+05:30	2025-12-30 12:27:38.863517+05:30
3bf929dc-dd53-4bee-9cb3-9bc330298e18	8c680c52-3535-48e0-b6ec-7c05723d75d3	Al Nahda	AND	2	t	2025-12-30 12:27:38.863517+05:30	2025-12-30 12:27:38.863517+05:30
38344d64-47f4-44bd-adf7-69647a4d8152	8c680c52-3535-48e0-b6ec-7c05723d75d3	Al Khan	AKN	3	t	2025-12-30 12:27:38.863517+05:30	2025-12-30 12:27:38.863517+05:30
82240b5c-0fff-45e4-b087-0d8442464f66	8c680c52-3535-48e0-b6ec-7c05723d75d3	Al Taawun	ATW	4	t	2025-12-30 12:27:38.863517+05:30	2025-12-30 12:27:38.863517+05:30
\.


--
-- TOC entry 4394 (class 0 OID 65703)
-- Dependencies: 232
-- Data for Name: maintenance_tickets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_tickets (id, company_id, created_at, updated_at, ticket_number, ticket_type, villa_id, site_id, space_id, created_by, title, description, location_detail, status, priority, category_id, contact_number, alternate_contact, preferred_time, department_id, assigned_supervisor_id, supervisor_assigned_at, assigned_technician_id, assigned_by, assigned_at, acknowledged_by, acknowledged_at, scheduled_at, technician_notes, resolution_notes, completed_at, closed_at, auto_close_at, tenant_confirmed, assigned_team_id, parent_ticket_id, is_escalated, escalation_level, escalated_at, villa_number, priority_id, rating, rating_comment, rated_at, rated_by) FROM stdin;
05facf4d-61bf-4457-bdfd-fd17ce140971	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:47:54.458898	2025-12-26 16:52:18.751476	TKT-2025-0008	MAINTENANCE	\N	\N	\N	d105993f-6f85-4144-ba14-dd361ae6df2e	Water Leak from Restroom Pipe	A water leak has been observed originating from a pipe within the restroom. Inspection and repair are required.	Restroom	COMPLETED	HIGH	\N	\N	\N	2025-12-26T16:47:00.000/2025-12-26T17:47:00.000	\N	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 16:49:22.633+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 16:49:06.581+05:30	\N	resolved. it was a minior damge	\N	2025-12-26 16:51:23.731+05:30	2025-12-26 16:52:18.749+05:30	\N	t	\N	\N	f	0	\N	A-275	\N	\N	\N	\N	\N
bd53d25e-e200-4720-9c48-b33871e16a95	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:49:14.874103	2025-12-30 12:49:14.874103	TKT-2025-0013	MAINTENANCE	\N	\N	\N	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	Fire Incident in Bedroom	Active fire reported in the specified bedroom location. Immediate emergency response required.	Bedroom	NEW	URGENT	\N	\N	\N	2025-12-30T12:49:00.000/2025-12-30T13:49:00.000	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	A-324	\N	\N	\N	\N	\N
419cd45a-d38d-4859-8043-cbfe96db48b0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:02:03.96034	2025-12-31 10:02:03.96034	TKT-2025-0015	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Active Fire Detected in Main Electrical Switch Board	Active fire detected within the main electrical switch board. Immediate response and isolation required.	Main Switch	NEW	URGENT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
04be10c5-23c9-4299-befd-94632df7e182	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.256214	2026-01-01 07:41:55.256214	TKT-2026-0001	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Water Pipe Leaking	A water pipe is currently leaking. Inspection and repair are required immediately to prevent water damage.	\N	NEW	HIGH	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
718a30f0-863e-402b-a131-e3c341cdefbc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:00:34.575312	2025-12-26 17:02:36.938477	TKT-2025-0009	MAINTENANCE	\N	\N	\N	d105993f-6f85-4144-ba14-dd361ae6df2e	Broken Chair Requires Repair/Replacement	A chair is broken and requires inspection, repair, or replacement.	hall	COMPLETED	MEDIUM	\N	\N	\N	2025-12-26T17:00:00.000/2025-12-26T18:00:00.000	\N	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 17:00:49.871+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 17:00:47.268+05:30	\N	\N	\N	2025-12-26 17:02:03.071+05:30	2025-12-26 17:02:36.936+05:30	\N	t	\N	\N	f	0	\N	A-275	\N	\N	\N	\N	\N
0b37442e-a901-48e9-ba00-bc7bf49c3a1d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:55:48.357741	2025-12-30 18:13:44.537528	TKT-2025-0014	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Fire Incident in Kitchen	Active fire reported within the kitchen area. Immediate emergency response required.	Kitchen	COMPLETED	URGENT	\N	\N	\N	\N	\N	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	44142ebb-779d-4e83-b0a2-3db691e389ff	2025-12-30 18:01:30.249+05:30	44142ebb-779d-4e83-b0a2-3db691e389ff	2025-12-30 18:01:30.237+05:30	\N	\N	\N	2025-12-30 18:01:58.62+05:30	2025-12-30 18:08:47.398+05:30	\N	t	\N	\N	f	0	\N	84	\N	4	\N	2025-12-30 18:13:44.524+05:30	95791439-c679-4dec-98cf-1eccedd65a87
553788fb-7388-434c-b04c-be87691d4ecc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:03:53.184024	2025-12-31 10:03:53.184024	TKT-2025-0016	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Fire reported in the hall area	Emergency services are required immediately due to a reported fire incident in the hall area.	Hall	NEW	URGENT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
b3167e24-7241-4858-b78d-75affe56707f	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.282838	2026-01-01 07:51:22.282838	TKT-2026-0002	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	AC Unit Malfunction in Bedroom	The air conditioning unit located in the bedroom is reported as non-functional and requires inspection and repair.	Bedroom	NEW	MEDIUM	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:18:13.136394	2025-12-26 17:20:55.576375	TKT-2025-0010	MAINTENANCE	\N	\N	\N	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	Air Conditioning Unit Failure in Main Hall	The air conditioning unit serving the main hall is currently non-functional and requires immediate inspection and repair.	Main Hall	COMPLETED	HIGH	\N	\N	\N	2025-12-26T17:17:00.000/2025-12-26T18:17:00.000	\N	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 17:19:27.552+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 17:19:20.421+05:30	\N	\N	\N	2025-12-26 17:20:32.047+05:30	2025-12-26 17:20:55.57+05:30	\N	t	\N	\N	f	0	\N	A-324	\N	\N	\N	\N	\N
518a030e-4357-4aaa-b019-03657ca5e722	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.687901	2026-01-01 07:57:47.687901	TKT-2026-0003	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Broken Water Pipe in Hallway	A water pipe is reported as broken in the main hallway, requiring immediate plumbing repair to prevent water damage.	Hall	NEW	HIGH	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
91f281b9-f724-4226-b12e-062f987dc6d8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:46:18.364845	2025-12-26 17:48:36.210131	TKT-2025-0011	MAINTENANCE	\N	\N	\N	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	Water Leak Detected in Kitchen	Water leak detected in the kitchen area.	Kitchen	COMPLETED	HIGH	\N	\N	\N	2025-12-26T17:46:00.000/2025-12-26T18:46:00.000	\N	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 17:46:56.144+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 17:46:53.041+05:30	\N	\N	\N	2025-12-26 17:48:02.744+05:30	2025-12-26 17:48:36.205+05:30	\N	t	\N	\N	f	0	\N	A-324	\N	\N	\N	\N	\N
db1f2cb5-59c4-4e04-a340-ac894fc68772	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.087258	2026-01-01 08:29:57.248359	TKT-2026-0004	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Broken Pipe Requiring Immediate Repair	A pipe is broken, requiring immediate inspection and repair to prevent potential water damage.	\N	CANCELLED	HIGH	af8c4095-6700-48e9-83bc-58f4cbe7eb98	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
f22f9ddc-e255-4310-b37d-f607174bc053	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:17:53.964168	2025-12-26 18:25:04.378477	TKT-2025-0012	MAINTENANCE	\N	\N	\N	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	Broken Pipe in Kitchen Requiring Immediate Repair	A pipe has broken in the kitchen area, requiring immediate plumbing repair.	Kitchen	COMPLETED	HIGH	\N	\N	\N	2025-12-26T18:17:00.000/2025-12-26T19:17:00.000	\N	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 18:19:30.209+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 18:19:23.173+05:30	\N	\N	\N	2025-12-26 18:22:56.052+05:30	2025-12-26 18:25:04.377+05:30	\N	t	\N	\N	f	0	\N	A-324	\N	\N	\N	\N	\N
aaa499ab-e07f-441a-be77-6305ecf7220f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000145	MAINTENANCE	\N	\N	\N	5fb6cc19-15bc-43c0-82ad-5a55f3ddf1db	Window Won't Close Properly	Bedroom window cannot be closed completely. Security concern.	\N	ACKNOWLEDGED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	3	\N	\N	\N	\N	\N
3483f1de-1d2a-429f-af59-9b3cf4700680	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000001	MAINTENANCE	\N	\N	\N	5e21829a-b5e3-4498-bb83-e912d258e2b8	Leaky Faucet in Kitchen	The kitchen faucet is leaking continuously. Water is dripping from the base and handle.	\N	NEW	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	48	\N	\N	\N	\N	\N
fa7c3c70-4a2f-4251-91ea-22df5ffc7fcf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000002	MAINTENANCE	\N	\N	\N	42264350-62a4-4119-b213-4e2f68ebe513	AC Not Cooling	Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.	\N	COMPLETED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-12 23:58:30.815+05:30	\N	\N	2025-12-12 23:58:30.815+05:30	Work in progress. HVAC issue being addressed.	Issue resolved. HVAC work completed successfully.	2025-12-17 02:58:30.815+05:30	\N	\N	t	\N	\N	f	0	\N	34	\N	\N	\N	\N	\N
82dd8690-aba5-4e40-9161-75f974115a2e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000003	MAINTENANCE	\N	\N	\N	2882fe7b-13dd-4184-94da-d8b80c2a06c7	Broken Light Switch	Light switch in living room is not working. Need to replace the switch.	\N	ASSIGNED	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-17 07:26:30.816+05:30	\N	\N	\N	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	28	\N	\N	\N	\N	\N
3df03256-c410-4069-af89-929fea564c7f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000004	MAINTENANCE	\N	\N	\N	8bcb8775-4b58-4050-85f8-885a9b8b0fe4	Garbage Disposal Not Working	Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.	\N	NEW	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	19	\N	\N	\N	\N	\N
a0385bc4-a031-4334-b680-fdd2e1beecde	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000005	MAINTENANCE	\N	\N	\N	2c4ad4f5-3790-4cba-b383-bab4e583109f	Window Won't Close Properly	Bedroom window cannot be closed completely. Security concern.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-18 16:49:30.818+05:30	\N	\N	2025-12-20 16:49:30.818+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	7	\N	\N	\N	\N	\N
33cc2382-ded5-4bf5-a274-8c1bc8b6dd68	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000006	MAINTENANCE	\N	\N	\N	2c4ad4f5-3790-4cba-b383-bab4e583109f	Heater Not Working	Heating system is not functioning. Very cold inside the villa.	\N	NEW	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	7	\N	\N	\N	\N	\N
d054d4d8-584c-4f2e-9fd8-bac4a5fbb2a2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000031	MAINTENANCE	\N	\N	\N	e59de9e0-b09d-40fd-9924-3aba2fb86d7b	Ceiling Fan Making Noise	Ceiling fan in bedroom is making loud grinding noise. Needs inspection.	\N	ACKNOWLEDGED	LOW	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	58	\N	\N	\N	\N	\N
2b3a65f7-06fe-4e86-8aa2-8a412edc2dcc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000146	MAINTENANCE	\N	\N	\N	b1469661-e285-4513-ac3d-fffcc131daa6	Heater Not Working	Heating system is not functioning. Very cold inside the villa.	\N	ON_HOLD	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-27 18:19:30.91+05:30	\N	\N	2025-11-28 18:19:30.91+05:30	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	4	\N	\N	\N	\N	\N
1976a796-bba2-4866-8e31-ccdc5f1d74b1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000147	MAINTENANCE	\N	\N	\N	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	Power Outlet Not Working	Power outlet in bedroom is not providing electricity. Checked with multiple devices.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-07 10:06:30.911+05:30	\N	\N	2025-12-09 10:06:30.911+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	33	\N	\N	\N	\N	\N
690f0596-52d5-4dda-8828-c9dccd8a66e6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000148	MAINTENANCE	\N	\N	\N	4fd836c0-e4b7-4de5-ae7d-57a9d29b7325	Toilet Running Continuously	Toilet keeps running water even after flushing. Wasting water.	\N	ACKNOWLEDGED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
d0b4be94-6851-4de4-84f5-d2225dd8b07f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000007	MAINTENANCE	\N	\N	\N	b18189ca-de52-4473-abc4-4e019eb74fef	Power Outlet Not Working	Power outlet in bedroom is not providing electricity. Checked with multiple devices.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-19 18:51:30.819+05:30	\N	\N	2025-12-21 18:51:30.819+05:30	Work in progress. Electrical issue being addressed.	Issue resolved. Electrical work completed successfully.	2025-12-23 22:51:30.819+05:30	\N	\N	t	\N	\N	f	0	\N	27	\N	\N	\N	\N	\N
6be7d5bb-37b1-422e-a11a-846b24dee100	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000008	MAINTENANCE	\N	\N	\N	2c4ad4f5-3790-4cba-b383-bab4e583109f	Toilet Running Continuously	Toilet keeps running water even after flushing. Wasting water.	\N	ACKNOWLEDGED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	7	\N	\N	\N	\N	\N
0fe27475-1bbc-4a4a-9f0b-0ac758ec46e8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000009	MAINTENANCE	\N	\N	\N	0018a2fa-7431-421b-b0a6-6fdbd5878622	Door Lock Malfunction	Main entrance door lock is not responding properly. Sometimes key gets stuck.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-19 19:46:30.821+05:30	\N	\N	\N	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	57	\N	\N	\N	\N	\N
18a7e380-6296-4cfa-9e7a-f557a11e43c3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000010	MAINTENANCE	\N	\N	\N	e59de9e0-b09d-40fd-9924-3aba2fb86d7b	Water Pressure Low	Water pressure in shower and kitchen sink is very low. Inconsistent flow.	\N	ACKNOWLEDGED	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	58	\N	\N	\N	\N	\N
9b9c9474-8ce9-4980-b564-44947ca428a5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000011	MAINTENANCE	\N	\N	\N	390bd96a-c854-416d-8660-802e754dfe30	Ceiling Fan Making Noise	Ceiling fan in bedroom is making loud grinding noise. Needs inspection.	\N	ASSIGNED	LOW	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-04 14:14:30.822+05:30	\N	\N	\N	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	9	\N	\N	\N	\N	\N
e693d5dd-7e78-429e-8fc5-9f6f01956cfe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000012	MAINTENANCE	\N	\N	\N	fd842408-0197-42b3-b459-d674809b1276	Garden Sprinkler Broken	Garden sprinkler system is not working. Some sprinklers are not turning on.	\N	ASSIGNED	LOW	\N	\N	\N	\N	e0d8cb45-3a1f-47b9-b1fb-ec0f317e4ed4	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-20 16:50:30.823+05:30	\N	\N	\N	Work in progress. Landscaping issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	25	\N	\N	\N	\N	\N
5b4857ca-8af7-4b93-b9f7-0eb0fbfc1175	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000013	MAINTENANCE	\N	\N	\N	0eb03419-5169-4605-a380-679a5d9faf95	Smoke Detector Beeping	Smoke detector is beeping continuously. Battery may need replacement.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-30 12:45:30.824+05:30	\N	\N	2025-11-30 12:45:30.824+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	10	\N	\N	\N	\N	\N
70158969-a9f5-4346-bf1b-fb3259bbcb25	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000014	MAINTENANCE	\N	\N	\N	b18189ca-de52-4473-abc4-4e019eb74fef	Washing Machine Drain Issue	Washing machine drain is backing up. Water not draining properly.	\N	ON_HOLD	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-13 17:51:30.825+05:30	\N	\N	2025-12-15 17:51:30.825+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	27	\N	\N	\N	\N	\N
fd6fc370-f9d6-4c77-9ce6-bceff8565c2d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000015	MAINTENANCE	\N	\N	\N	cffd4755-5598-42df-8634-68beb98c13a4	AC Filter Replacement Needed	AC filter is dirty and needs replacement. Air quality is poor.	\N	ASSIGNED	LOW	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-09 00:57:30.826+05:30	\N	\N	\N	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	65	\N	\N	\N	\N	\N
d740e963-adab-4bda-b64a-6a038243fa3a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000016	MAINTENANCE	\N	\N	\N	60803f2d-364d-4286-8fdc-8248485b9b82	Broken Window Blind	Window blind in living room is broken. Cannot open or close properly.	\N	COMPLETED	LOW	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-01 08:04:30.827+05:30	\N	\N	2025-12-01 08:04:30.827+05:30	Work in progress. General Maintenance issue being addressed.	Issue resolved. General Maintenance work completed successfully.	2025-12-06 14:04:30.827+05:30	\N	\N	t	\N	\N	f	0	\N	21	\N	\N	\N	\N	\N
a6fbdc53-f6c7-42ba-be50-c1e146f3c9e2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000017	MAINTENANCE	\N	\N	\N	1d97134a-1b6a-47da-b3da-9324aa1a2f69	Refrigerator Not Cooling	Refrigerator is not maintaining cold temperature. Food is spoiling.	\N	ASSIGNED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-27 01:10:30.828+05:30	\N	\N	\N	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	1	\N	\N	\N	\N	\N
9928873f-639a-4a70-8c1a-fe39a8f5f4fd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000018	MAINTENANCE	\N	\N	\N	148547a8-d99f-4fb4-bb01-5bb7c6f2b159	Shower Head Leaking	Shower head is leaking from multiple points. Water spraying everywhere.	\N	NEW	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	30	\N	\N	\N	\N	\N
38cf0d4d-b362-4578-941e-40973a06d818	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000019	MAINTENANCE	\N	\N	\N	8eb63fe5-7d76-48a0-9456-36d698f469ed	Garage Door Opener Not Working	Garage door opener remote is not working. Door cannot be opened remotely.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-18 03:18:30.829+05:30	\N	\N	2025-12-18 03:18:30.829+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	16	\N	\N	\N	\N	\N
0d3492db-db3b-49d0-a01d-fe447ae3136e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000020	MAINTENANCE	\N	\N	\N	c9bc0f9b-4414-4242-bb3f-ff992ef747e1	Pool Pump Making Noise	Pool pump is making loud noise. May need maintenance or replacement.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-13 11:25:30.83+05:30	\N	\N	2025-12-13 11:25:30.83+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	47	\N	\N	\N	\N	\N
c8c673c3-45df-45a8-85d1-99518bfa243a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000021	MAINTENANCE	\N	\N	\N	98c7399e-0621-457a-b93b-d8eeaaac4630	Leaky Faucet in Kitchen	The kitchen faucet is leaking continuously. Water is dripping from the base and handle.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-30 02:36:30.831+05:30	\N	\N	2025-11-30 02:36:30.831+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	59	\N	\N	\N	\N	\N
e7460bfc-e80c-4022-ab82-ecee90db98c9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000022	MAINTENANCE	\N	\N	\N	71e291b7-f092-40b6-9819-8fc848682e6a	AC Not Cooling	Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.	\N	IN_PROGRESS	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-12 18:00:30.831+05:30	\N	\N	2025-12-13 18:00:30.831+05:30	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	8	\N	\N	\N	\N	\N
dc3fab29-8aa4-48c5-b397-0e345f501293	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000023	MAINTENANCE	\N	\N	\N	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	Broken Light Switch	Light switch in living room is not working. Need to replace the switch.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-03 08:48:30.832+05:30	\N	\N	2025-12-05 08:48:30.832+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	79	\N	\N	\N	\N	\N
fbd21f2c-a3d4-4511-a9ee-315b4c01dc8c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000024	MAINTENANCE	\N	\N	\N	53bde808-7662-4bfc-a407-54fd1b83b4f6	Garbage Disposal Not Working	Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.	\N	ACKNOWLEDGED	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	49	\N	\N	\N	\N	\N
d1e028f8-1539-4598-97a9-86e8b9c94c90	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000025	MAINTENANCE	\N	\N	\N	ccdaf2d6-3905-4d04-b7a9-c6ac5c3ac2d0	Window Won't Close Properly	Bedroom window cannot be closed completely. Security concern.	\N	NEW	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	14	\N	\N	\N	\N	\N
eb1893f3-5cab-403c-a696-abd7bcdf6061	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000026	MAINTENANCE	\N	\N	\N	398a1e8a-ff59-49d9-a52f-86d0270964ff	Heater Not Working	Heating system is not functioning. Very cold inside the villa.	\N	NEW	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	23	\N	\N	\N	\N	\N
56e49a79-aafa-410e-abf7-edc43c25558a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000027	MAINTENANCE	\N	\N	\N	c9bc0f9b-4414-4242-bb3f-ff992ef747e1	Power Outlet Not Working	Power outlet in bedroom is not providing electricity. Checked with multiple devices.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-09 19:27:30.835+05:30	\N	\N	2025-12-11 19:27:30.835+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	47	\N	\N	\N	\N	\N
fc3c7dca-0075-4363-ae60-1893d1e9a33c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000028	MAINTENANCE	\N	\N	\N	4cb39fa4-be14-4a89-9fae-f88ea5406111	Toilet Running Continuously	Toilet keeps running water even after flushing. Wasting water.	\N	ON_HOLD	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-25 14:57:30.835+05:30	\N	\N	2025-11-25 14:57:30.835+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	37	\N	\N	\N	\N	\N
b25cb650-037f-46ea-8c28-538db34c3703	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000029	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Door Lock Malfunction	Main entrance door lock is not responding properly. Sometimes key gets stuck.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-24 12:36:30.836+05:30	\N	\N	2025-11-25 12:36:30.836+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	86	\N	\N	\N	\N	\N
46f7e756-b3b9-4124-9bf3-b885a2374483	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000030	MAINTENANCE	\N	\N	\N	676ad3ae-87fa-4a38-8bf7-2debba141c77	Water Pressure Low	Water pressure in shower and kitchen sink is very low. Inconsistent flow.	\N	NEW	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	70	\N	\N	\N	\N	\N
229a7341-f132-4ad4-8819-0a05db1e4ad6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000032	MAINTENANCE	\N	\N	\N	e4072a3c-cca1-44cf-a465-dcf6281fbcd3	Garden Sprinkler Broken	Garden sprinkler system is not working. Some sprinklers are not turning on.	\N	IN_PROGRESS	LOW	\N	\N	\N	\N	e0d8cb45-3a1f-47b9-b1fb-ec0f317e4ed4	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-02 13:39:30.838+05:30	\N	\N	2025-12-04 13:39:30.838+05:30	Work in progress. Landscaping issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	76	\N	\N	\N	\N	\N
c8af4b35-197f-4240-93d7-a74545bda5fc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000033	MAINTENANCE	\N	\N	\N	b4968123-7908-457a-9e7c-2ae17c8fadaa	Smoke Detector Beeping	Smoke detector is beeping continuously. Battery may need replacement.	\N	ACKNOWLEDGED	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	20	\N	\N	\N	\N	\N
dd9c787e-d752-4c50-af6f-0cc607af8ab6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000034	MAINTENANCE	\N	\N	\N	2c4ad4f5-3790-4cba-b383-bab4e583109f	Washing Machine Drain Issue	Washing machine drain is backing up. Water not draining properly.	\N	ACKNOWLEDGED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	7	\N	\N	\N	\N	\N
49f97491-3f7e-4d96-928c-047dc634c252	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000035	MAINTENANCE	\N	\N	\N	03b5e215-5057-405c-9ba4-a3485b1d0c89	AC Filter Replacement Needed	AC filter is dirty and needs replacement. Air quality is poor.	\N	COMPLETED	LOW	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-24 03:50:30.839+05:30	\N	\N	2025-11-26 03:50:30.839+05:30	Work in progress. HVAC issue being addressed.	Issue resolved. HVAC work completed successfully.	2025-11-27 05:50:30.839+05:30	\N	\N	f	\N	\N	f	0	\N	32	\N	\N	\N	\N	\N
58520a13-24ec-4870-bd55-01384a49de1f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000036	MAINTENANCE	\N	\N	\N	5e21829a-b5e3-4498-bb83-e912d258e2b8	Broken Window Blind	Window blind in living room is broken. Cannot open or close properly.	\N	NEW	LOW	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	48	\N	\N	\N	\N	\N
50f91c3e-49e2-410a-920f-7302fe0d84cd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000037	MAINTENANCE	\N	\N	\N	71e291b7-f092-40b6-9819-8fc848682e6a	Refrigerator Not Cooling	Refrigerator is not maintaining cold temperature. Food is spoiling.	\N	ASSIGNED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-27 13:30:30.841+05:30	\N	\N	\N	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	8	\N	\N	\N	\N	\N
55ec17c2-5686-46ac-9240-d6b665ed9db6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000038	MAINTENANCE	\N	\N	\N	38d853ee-2655-4675-94c3-32aa7c6710e9	Shower Head Leaking	Shower head is leaking from multiple points. Water spraying everywhere.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-10 05:39:30.841+05:30	\N	\N	2025-12-11 05:39:30.841+05:30	Work in progress. Plumbing issue being addressed.	Issue resolved. Plumbing work completed successfully.	2025-12-13 08:39:30.841+05:30	\N	\N	t	\N	\N	f	0	\N	66	\N	\N	\N	\N	\N
24f292cd-f246-40c7-8327-15a6b344138d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000039	MAINTENANCE	\N	\N	\N	cffd4755-5598-42df-8634-68beb98c13a4	Garage Door Opener Not Working	Garage door opener remote is not working. Door cannot be opened remotely.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-30 01:57:30.842+05:30	\N	\N	2025-12-02 01:57:30.842+05:30	Work in progress. General Maintenance issue being addressed.	Issue resolved. General Maintenance work completed successfully.	2025-12-07 08:57:30.842+05:30	\N	\N	t	\N	\N	f	0	\N	65	\N	\N	\N	\N	\N
2ad0523c-cf89-419a-835b-212d99bb0cef	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000040	MAINTENANCE	\N	\N	\N	1da9779d-0ee5-4a93-8e48-254e19ea71eb	Pool Pump Making Noise	Pool pump is making loud noise. May need maintenance or replacement.	\N	ACKNOWLEDGED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	68	\N	\N	\N	\N	\N
29287320-4b90-4196-abae-3bec8e4a7236	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000041	MAINTENANCE	\N	\N	\N	a20f0416-b723-4615-b9dd-644a7cee6f75	Leaky Faucet in Kitchen	The kitchen faucet is leaking continuously. Water is dripping from the base and handle.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-03 04:44:30.844+05:30	\N	\N	\N	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	72	\N	\N	\N	\N	\N
f09b9832-337a-4814-be81-625fea594863	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000042	MAINTENANCE	\N	\N	\N	9fc4ca33-d77a-452f-aa97-677485aa2285	AC Not Cooling	Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.	\N	NEW	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	80	\N	\N	\N	\N	\N
e6488155-09dd-4389-87a5-01ba3fd96ed9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000043	MAINTENANCE	\N	\N	\N	390bd96a-c854-416d-8660-802e754dfe30	Broken Light Switch	Light switch in living room is not working. Need to replace the switch.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-01 01:33:30.844+05:30	\N	\N	2025-12-01 01:33:30.844+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	9	\N	\N	\N	\N	\N
d9d8a1e7-a9de-40dc-8ce4-e92dfa4efd6c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000044	MAINTENANCE	\N	\N	\N	71e291b7-f092-40b6-9819-8fc848682e6a	Garbage Disposal Not Working	Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-17 16:58:30.845+05:30	\N	\N	2025-12-17 16:58:30.845+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	8	\N	\N	\N	\N	\N
c426b74b-ff34-409f-9c41-4ad1e0150ec1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000045	MAINTENANCE	\N	\N	\N	93d899ce-d497-4f95-82b2-fe293db75dc5	Window Won't Close Properly	Bedroom window cannot be closed completely. Security concern.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-19 07:53:30.846+05:30	\N	\N	\N	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	41	\N	\N	\N	\N	\N
9d0b2fa8-24b3-4f3c-8e12-7462216ec8c4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000046	MAINTENANCE	\N	\N	\N	d66b699b-9605-4c11-9730-dcb26df0f882	Heater Not Working	Heating system is not functioning. Very cold inside the villa.	\N	COMPLETED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-25 06:02:30.847+05:30	\N	\N	2025-11-25 06:02:30.847+05:30	Work in progress. HVAC issue being addressed.	Issue resolved. HVAC work completed successfully.	2025-11-26 13:02:30.847+05:30	\N	\N	f	\N	\N	f	0	\N	78	\N	\N	\N	\N	\N
37015f24-5085-4c4e-b322-90a753484047	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000047	MAINTENANCE	\N	\N	\N	d0836e66-8c5a-4a56-985e-c04f2bea6fc4	Power Outlet Not Working	Power outlet in bedroom is not providing electricity. Checked with multiple devices.	\N	ASSIGNED	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-30 01:09:30.847+05:30	\N	\N	\N	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	64	\N	\N	\N	\N	\N
7f393ced-e1ba-4d5c-b13b-1f345c1edafb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000048	MAINTENANCE	\N	\N	\N	61e3614b-3b90-47a9-baf7-ecf8e7a6b96c	Toilet Running Continuously	Toilet keeps running water even after flushing. Wasting water.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-06 10:58:30.848+05:30	\N	\N	\N	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	35	\N	\N	\N	\N	\N
ddb67e47-6372-4951-8456-cc6405d01753	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000049	MAINTENANCE	\N	\N	\N	61e3614b-3b90-47a9-baf7-ecf8e7a6b96c	Door Lock Malfunction	Main entrance door lock is not responding properly. Sometimes key gets stuck.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-06 20:15:30.849+05:30	\N	\N	\N	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	35	\N	\N	\N	\N	\N
d767bd60-db09-45ee-adc4-817379fb527e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000050	MAINTENANCE	\N	\N	\N	b18189ca-de52-4473-abc4-4e019eb74fef	Water Pressure Low	Water pressure in shower and kitchen sink is very low. Inconsistent flow.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-05 06:49:30.849+05:30	\N	\N	2025-12-07 06:49:30.849+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	27	\N	\N	\N	\N	\N
c6fd1853-c133-4b7a-8117-5a4e78d56807	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000051	MAINTENANCE	\N	\N	\N	457cc731-4a14-462c-bba5-c0a67fe2b0e4	Ceiling Fan Making Noise	Ceiling fan in bedroom is making loud grinding noise. Needs inspection.	\N	IN_PROGRESS	LOW	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-30 06:58:30.85+05:30	\N	\N	2025-12-01 06:58:30.85+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	24	\N	\N	\N	\N	\N
4507aa38-8187-42c3-a91e-aca1d2dc88fc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000052	MAINTENANCE	\N	\N	\N	2df7ef09-1682-43c9-9c64-e479c86c1c1e	Garden Sprinkler Broken	Garden sprinkler system is not working. Some sprinklers are not turning on.	\N	ACKNOWLEDGED	LOW	\N	\N	\N	\N	e0d8cb45-3a1f-47b9-b1fb-ec0f317e4ed4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	36	\N	\N	\N	\N	\N
f181e42a-b99a-41bf-872e-8623f0e9049b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000053	MAINTENANCE	\N	\N	\N	0018a2fa-7431-421b-b0a6-6fdbd5878622	Smoke Detector Beeping	Smoke detector is beeping continuously. Battery may need replacement.	\N	NEW	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	57	\N	\N	\N	\N	\N
4f3dbf54-5988-46b5-954b-c30630926fc3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000054	MAINTENANCE	\N	\N	\N	5b91137f-8c0a-403f-8bd3-f26ba765e8a3	Washing Machine Drain Issue	Washing machine drain is backing up. Water not draining properly.	\N	ON_HOLD	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-26 03:31:30.853+05:30	\N	\N	2025-11-27 03:31:30.853+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	67	\N	\N	\N	\N	\N
312117bb-d37b-4740-93ed-2d9387571c97	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000055	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	AC Filter Replacement Needed	AC filter is dirty and needs replacement. Air quality is poor.	\N	ASSIGNED	LOW	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-24 01:27:30.854+05:30	\N	\N	\N	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	86	\N	\N	\N	\N	\N
e8ba105f-481f-4d03-8907-a74a76275de6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000056	MAINTENANCE	\N	\N	\N	0018a2fa-7431-421b-b0a6-6fdbd5878622	Broken Window Blind	Window blind in living room is broken. Cannot open or close properly.	\N	IN_PROGRESS	LOW	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-19 07:14:30.855+05:30	\N	\N	2025-12-19 07:14:30.855+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	57	\N	\N	\N	\N	\N
c8ad4aec-82b2-4bc4-8010-b66763e3f1c8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000057	MAINTENANCE	\N	\N	\N	ec44affc-f5ff-40ef-a3de-b8f303fee488	Refrigerator Not Cooling	Refrigerator is not maintaining cold temperature. Food is spoiling.	\N	ON_HOLD	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-18 14:50:30.855+05:30	\N	\N	2025-12-19 14:50:30.855+05:30	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	54	\N	\N	\N	\N	\N
bb83d4b5-2fea-4677-9dbd-b53566cb9710	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000058	MAINTENANCE	\N	\N	\N	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	Shower Head Leaking	Shower head is leaking from multiple points. Water spraying everywhere.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-25 10:57:30.856+05:30	\N	\N	2025-11-25 10:57:30.856+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	79	\N	\N	\N	\N	\N
d270cb85-b3fe-4247-8b06-942f9ad4659c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000059	MAINTENANCE	\N	\N	\N	398a1e8a-ff59-49d9-a52f-86d0270964ff	Garage Door Opener Not Working	Garage door opener remote is not working. Door cannot be opened remotely.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-29 12:30:30.857+05:30	\N	\N	2025-12-01 12:30:30.857+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	23	\N	\N	\N	\N	\N
a3c2d4b5-703d-4f03-ac90-bda69671c748	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000060	MAINTENANCE	\N	\N	\N	0018a2fa-7431-421b-b0a6-6fdbd5878622	Pool Pump Making Noise	Pool pump is making loud noise. May need maintenance or replacement.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-09 08:02:30.858+05:30	\N	\N	\N	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	57	\N	\N	\N	\N	\N
b08e1d18-12b3-40e5-b109-3b64a853685c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000061	MAINTENANCE	\N	\N	\N	4cb39fa4-be14-4a89-9fae-f88ea5406111	Leaky Faucet in Kitchen	The kitchen faucet is leaking continuously. Water is dripping from the base and handle.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-22 12:32:30.858+05:30	\N	\N	\N	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	37	\N	\N	\N	\N	\N
59f8f6f4-fb27-40d3-a30c-bce98a0fd81b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000062	MAINTENANCE	\N	\N	\N	61b1fbb4-305b-406d-8906-b48d47be9faf	AC Not Cooling	Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.	\N	ON_HOLD	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-05 04:30:30.859+05:30	\N	\N	2025-12-06 04:30:30.859+05:30	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	82	\N	\N	\N	\N	\N
f5139e23-db44-449e-807b-2627b76c5a0f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000063	MAINTENANCE	\N	\N	\N	9bd4b184-458f-4eab-9472-6578042407e0	Broken Light Switch	Light switch in living room is not working. Need to replace the switch.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-05 09:11:30.86+05:30	\N	\N	2025-12-07 09:11:30.86+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	17	\N	\N	\N	\N	\N
0117f270-44ac-4b30-974a-7b099780466d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000064	MAINTENANCE	\N	\N	\N	cfb8af0f-11c6-464b-8e84-747f9cbdcb84	Garbage Disposal Not Working	Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-12 07:19:30.86+05:30	\N	\N	2025-12-14 07:19:30.86+05:30	Work in progress. Plumbing issue being addressed.	Issue resolved. Plumbing work completed successfully.	2025-12-18 13:19:30.86+05:30	\N	\N	f	\N	\N	f	0	\N	31	\N	\N	\N	\N	\N
49f1e87c-6599-44c1-aa4d-d46c1598ef88	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000065	MAINTENANCE	\N	\N	\N	aa1a0cdc-8202-4654-a28e-9bda086a3f84	Window Won't Close Properly	Bedroom window cannot be closed completely. Security concern.	\N	ACKNOWLEDGED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	6	\N	\N	\N	\N	\N
0d7aac42-22fa-4ea6-91c2-dfc653c21d4d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000066	MAINTENANCE	\N	\N	\N	53e744ac-828b-41ed-b12a-34f7829c1e38	Heater Not Working	Heating system is not functioning. Very cold inside the villa.	\N	IN_PROGRESS	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-10 06:32:30.862+05:30	\N	\N	2025-12-10 06:32:30.862+05:30	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	55	\N	\N	\N	\N	\N
06ffe742-cd5e-489e-bf00-368c6685e497	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000067	MAINTENANCE	\N	\N	\N	fd842408-0197-42b3-b459-d674809b1276	Power Outlet Not Working	Power outlet in bedroom is not providing electricity. Checked with multiple devices.	\N	NEW	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	25	\N	\N	\N	\N	\N
fd2db933-ec7c-4fdd-b6de-b87576e84947	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000068	MAINTENANCE	\N	\N	\N	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	Toilet Running Continuously	Toilet keeps running water even after flushing. Wasting water.	\N	ON_HOLD	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-20 00:34:30.863+05:30	\N	\N	2025-12-20 00:34:30.863+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	33	\N	\N	\N	\N	\N
fdba8078-0a22-4a34-8966-bd8240b9673a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000069	MAINTENANCE	\N	\N	\N	42264350-62a4-4119-b213-4e2f68ebe513	Door Lock Malfunction	Main entrance door lock is not responding properly. Sometimes key gets stuck.	\N	NEW	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	34	\N	\N	\N	\N	\N
47247a33-d78a-4e82-99df-953e70160e5f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000070	MAINTENANCE	\N	\N	\N	407f8619-e786-4515-8bbe-1676e3bbc361	Water Pressure Low	Water pressure in shower and kitchen sink is very low. Inconsistent flow.	\N	NEW	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	22	\N	\N	\N	\N	\N
48c598a0-566d-4c2a-9fd9-4bcb571543dd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000071	MAINTENANCE	\N	\N	\N	3a55a2a5-5792-4cac-8d1a-f89f2636b489	Ceiling Fan Making Noise	Ceiling fan in bedroom is making loud grinding noise. Needs inspection.	\N	ON_HOLD	LOW	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-20 12:43:30.864+05:30	\N	\N	2025-12-21 12:43:30.864+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	56	\N	\N	\N	\N	\N
27f6481f-b86d-4f5d-aa65-906dbc075588	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000072	MAINTENANCE	\N	\N	\N	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	Garden Sprinkler Broken	Garden sprinkler system is not working. Some sprinklers are not turning on.	\N	NEW	LOW	\N	\N	\N	\N	e0d8cb45-3a1f-47b9-b1fb-ec0f317e4ed4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	50	\N	\N	\N	\N	\N
ae436ed6-8123-45e2-9cbd-e4be8b07a5c0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000073	MAINTENANCE	\N	\N	\N	676ad3ae-87fa-4a38-8bf7-2debba141c77	Smoke Detector Beeping	Smoke detector is beeping continuously. Battery may need replacement.	\N	ASSIGNED	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-27 21:30:30.865+05:30	\N	\N	\N	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	70	\N	\N	\N	\N	\N
f09491ee-c2ad-4bf4-98a2-e36971a04b3a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000095	MAINTENANCE	\N	\N	\N	b1469661-e285-4513-ac3d-fffcc131daa6	AC Filter Replacement Needed	AC filter is dirty and needs replacement. Air quality is poor.	\N	NEW	LOW	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	4	\N	\N	\N	\N	\N
ac53749f-d494-49de-9b6a-1282b00b3776	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000074	MAINTENANCE	\N	\N	\N	9392dfcd-3eb4-428d-ab2f-fa38c0a33c90	Washing Machine Drain Issue	Washing machine drain is backing up. Water not draining properly.	\N	COMPLETED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-20 04:56:30.866+05:30	\N	\N	2025-12-21 04:56:30.866+05:30	Work in progress. Plumbing issue being addressed.	Issue resolved. Plumbing work completed successfully.	2025-12-25 09:56:30.866+05:30	\N	\N	f	\N	\N	f	0	\N	60	\N	\N	\N	\N	\N
9f98c423-a32d-4175-8275-a48cf0f6c070	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000075	MAINTENANCE	\N	\N	\N	071618e8-48df-4397-bf58-13500b13b963	AC Filter Replacement Needed	AC filter is dirty and needs replacement. Air quality is poor.	\N	COMPLETED	LOW	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-22 01:49:30.867+05:30	\N	\N	2025-12-22 01:49:30.867+05:30	Work in progress. HVAC issue being addressed.	Issue resolved. HVAC work completed successfully.	2025-12-27 04:49:30.867+05:30	\N	\N	t	\N	\N	f	0	\N	12	\N	\N	\N	\N	\N
c08ceec9-2909-4e7c-adf2-3087bf77c4a2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000076	MAINTENANCE	\N	\N	\N	470d6e78-cc9b-40a2-b365-25f7b3bba977	Broken Window Blind	Window blind in living room is broken. Cannot open or close properly.	\N	COMPLETED	LOW	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-05 19:33:30.868+05:30	\N	\N	2025-12-05 19:33:30.868+05:30	Work in progress. General Maintenance issue being addressed.	Issue resolved. General Maintenance work completed successfully.	2025-12-11 02:33:30.868+05:30	\N	\N	t	\N	\N	f	0	\N	52	\N	\N	\N	\N	\N
d1f05648-e3a1-4084-9cd1-f429391ef5dd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000077	MAINTENANCE	\N	\N	\N	53bde808-7662-4bfc-a407-54fd1b83b4f6	Refrigerator Not Cooling	Refrigerator is not maintaining cold temperature. Food is spoiling.	\N	COMPLETED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-20 17:42:30.868+05:30	\N	\N	2025-12-20 17:42:30.868+05:30	Work in progress. HVAC issue being addressed.	Issue resolved. HVAC work completed successfully.	2025-12-24 18:42:30.868+05:30	\N	\N	t	\N	\N	f	0	\N	49	\N	\N	\N	\N	\N
d7ef6216-24cc-47fb-9c12-d0a3e3f788e0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:04:24.393963	2025-12-24 12:04:24.393963	TKT-2025-0002	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Broken Chair in Hallway	A chair located in the main hall is broken and requires repair or replacement.	Main Hall	NEW	LOW	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	85	\N	\N	\N	\N	\N
ae0de313-ab6b-48ca-a4bb-df3805f5b5be	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000078	MAINTENANCE	\N	\N	\N	d4c313e9-9190-43d3-9280-4e19a3619f44	Shower Head Leaking	Shower head is leaking from multiple points. Water spraying everywhere.	\N	ASSIGNED	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-30 08:56:30.869+05:30	\N	\N	\N	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	40	\N	\N	\N	\N	\N
a940e004-f238-4caa-808c-2067a949c0c7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000079	MAINTENANCE	\N	\N	\N	bb9480ff-bee6-48a3-bd70-a927f8faa96e	Garage Door Opener Not Working	Garage door opener remote is not working. Door cannot be opened remotely.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-23 12:16:30.87+05:30	\N	\N	2025-11-24 12:16:30.87+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	81	\N	\N	\N	\N	\N
0e8a466e-b8f4-420a-8979-827b3e5472d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000080	MAINTENANCE	\N	\N	\N	457cc731-4a14-462c-bba5-c0a67fe2b0e4	Pool Pump Making Noise	Pool pump is making loud noise. May need maintenance or replacement.	\N	COMPLETED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-02 13:09:30.871+05:30	\N	\N	2025-12-04 13:09:30.871+05:30	Work in progress. General Maintenance issue being addressed.	Issue resolved. General Maintenance work completed successfully.	2025-12-05 16:09:30.871+05:30	\N	\N	f	\N	\N	f	0	\N	24	\N	\N	\N	\N	\N
e9f0c22d-00a7-4a46-98ae-410638a954a4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000081	MAINTENANCE	\N	\N	\N	bb9480ff-bee6-48a3-bd70-a927f8faa96e	Leaky Faucet in Kitchen	The kitchen faucet is leaking continuously. Water is dripping from the base and handle.	\N	COMPLETED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-17 17:32:30.871+05:30	\N	\N	2025-12-17 17:32:30.871+05:30	Work in progress. Plumbing issue being addressed.	Issue resolved. Plumbing work completed successfully.	2025-12-20 23:32:30.871+05:30	\N	\N	t	\N	\N	f	0	\N	81	\N	\N	\N	\N	\N
7759c876-cd74-4f8d-b62c-b33b90c16dcc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000082	MAINTENANCE	\N	\N	\N	53bde808-7662-4bfc-a407-54fd1b83b4f6	AC Not Cooling	Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.	\N	ON_HOLD	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-26 05:40:30.872+05:30	\N	\N	2025-11-28 05:40:30.872+05:30	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	49	\N	\N	\N	\N	\N
f59922f9-dc91-4d25-81a4-e06b5834c319	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000083	MAINTENANCE	\N	\N	\N	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	Broken Light Switch	Light switch in living room is not working. Need to replace the switch.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-20 08:42:30.873+05:30	\N	\N	2025-12-20 08:42:30.873+05:30	Work in progress. Electrical issue being addressed.	Issue resolved. Electrical work completed successfully.	2025-12-22 16:42:30.873+05:30	\N	\N	t	\N	\N	f	0	\N	50	\N	\N	\N	\N	\N
3b5253c9-3336-414e-b33a-708d6efe2627	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000084	MAINTENANCE	\N	\N	\N	bb9480ff-bee6-48a3-bd70-a927f8faa96e	Garbage Disposal Not Working	Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-27 03:05:30.874+05:30	\N	\N	2025-11-28 03:05:30.874+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	81	\N	\N	\N	\N	\N
17011426-113f-4c9e-9e39-2af737bf3e78	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000085	MAINTENANCE	\N	\N	\N	f4c87468-fa82-45fc-aa90-d3668f808a3b	Window Won't Close Properly	Bedroom window cannot be closed completely. Security concern.	\N	COMPLETED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-26 22:05:30.874+05:30	\N	\N	2025-11-27 22:05:30.874+05:30	Work in progress. General Maintenance issue being addressed.	Issue resolved. General Maintenance work completed successfully.	2025-12-01 05:05:30.874+05:30	\N	\N	t	\N	\N	f	0	\N	69	\N	\N	\N	\N	\N
5ce985d3-b498-416d-8d4f-a0f52bb604ae	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000086	MAINTENANCE	\N	\N	\N	4fd836c0-e4b7-4de5-ae7d-57a9d29b7325	Heater Not Working	Heating system is not functioning. Very cold inside the villa.	\N	COMPLETED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-13 04:24:30.875+05:30	\N	\N	2025-12-14 04:24:30.875+05:30	Work in progress. HVAC issue being addressed.	Issue resolved. HVAC work completed successfully.	2025-12-15 12:24:30.875+05:30	\N	\N	t	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
ecae75ba-5e2e-4879-995f-ace34b448749	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000087	MAINTENANCE	\N	\N	\N	be7c2045-9191-4083-86c2-383c166520bc	Power Outlet Not Working	Power outlet in bedroom is not providing electricity. Checked with multiple devices.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-04 20:16:30.876+05:30	\N	\N	2025-12-04 20:16:30.876+05:30	Work in progress. Electrical issue being addressed.	Issue resolved. Electrical work completed successfully.	2025-12-09 21:16:30.876+05:30	\N	\N	t	\N	\N	f	0	\N	5	\N	\N	\N	\N	\N
978a5c77-b661-4721-9ddd-4905119082cc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000088	MAINTENANCE	\N	\N	\N	38a4ff0d-a3ad-4c48-b4e1-02706892b17d	Toilet Running Continuously	Toilet keeps running water even after flushing. Wasting water.	\N	COMPLETED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-06 01:00:30.876+05:30	\N	\N	2025-12-08 01:00:30.876+05:30	Work in progress. Plumbing issue being addressed.	Issue resolved. Plumbing work completed successfully.	2025-12-12 02:00:30.876+05:30	\N	\N	f	\N	\N	f	0	\N	39	\N	\N	\N	\N	\N
b830f3f9-6e16-4e24-baac-ea62cd733d08	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000089	MAINTENANCE	\N	\N	\N	8eb63fe5-7d76-48a0-9456-36d698f469ed	Door Lock Malfunction	Main entrance door lock is not responding properly. Sometimes key gets stuck.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-20 12:26:30.877+05:30	\N	\N	2025-12-20 12:26:30.877+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	16	\N	\N	\N	\N	\N
41f32279-440e-4414-b1e3-f4831973516e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000090	MAINTENANCE	\N	\N	\N	470d6e78-cc9b-40a2-b365-25f7b3bba977	Water Pressure Low	Water pressure in shower and kitchen sink is very low. Inconsistent flow.	\N	NEW	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	52	\N	\N	\N	\N	\N
87fee608-a356-4d57-943b-afe2cb2b8d0b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000091	MAINTENANCE	\N	\N	\N	61b1fbb4-305b-406d-8906-b48d47be9faf	Ceiling Fan Making Noise	Ceiling fan in bedroom is making loud grinding noise. Needs inspection.	\N	IN_PROGRESS	LOW	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-26 17:43:30.878+05:30	\N	\N	2025-11-27 17:43:30.878+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	82	\N	\N	\N	\N	\N
44566b99-cd8a-48b7-b0fd-8304ef3a8046	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000092	MAINTENANCE	\N	\N	\N	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	Garden Sprinkler Broken	Garden sprinkler system is not working. Some sprinklers are not turning on.	\N	NEW	LOW	\N	\N	\N	\N	e0d8cb45-3a1f-47b9-b1fb-ec0f317e4ed4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	33	\N	\N	\N	\N	\N
9c95e8a2-2cf2-488a-837a-ed24beddd397	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000093	MAINTENANCE	\N	\N	\N	0018a2fa-7431-421b-b0a6-6fdbd5878622	Smoke Detector Beeping	Smoke detector is beeping continuously. Battery may need replacement.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-27 17:00:30.879+05:30	\N	\N	2025-11-27 17:00:30.879+05:30	Work in progress. General Maintenance issue being addressed.	Issue resolved. General Maintenance work completed successfully.	2025-12-02 18:00:30.879+05:30	\N	\N	t	\N	\N	f	0	\N	57	\N	\N	\N	\N	\N
4f289ac7-d253-4083-a0f4-8be1986facb0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000094	MAINTENANCE	\N	\N	\N	d9361d85-2226-44be-b864-ad171091950c	Washing Machine Drain Issue	Washing machine drain is backing up. Water not draining properly.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-15 13:33:30.879+05:30	\N	\N	\N	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	44	\N	\N	\N	\N	\N
91abeae8-30fb-45db-bb02-422520cbe6ba	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000096	MAINTENANCE	\N	\N	\N	2c4ad4f5-3790-4cba-b383-bab4e583109f	Broken Window Blind	Window blind in living room is broken. Cannot open or close properly.	\N	IN_PROGRESS	LOW	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-11 12:52:30.88+05:30	\N	\N	2025-12-12 12:52:30.88+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	7	\N	\N	\N	\N	\N
8f74b68c-01f2-45ae-a411-0bc9ed3d11dc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000097	MAINTENANCE	\N	\N	\N	9826254b-4208-479f-af75-c59a0d88babb	Refrigerator Not Cooling	Refrigerator is not maintaining cold temperature. Food is spoiling.	\N	COMPLETED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-17 16:18:30.881+05:30	\N	\N	2025-12-19 16:18:30.881+05:30	Work in progress. HVAC issue being addressed.	Issue resolved. HVAC work completed successfully.	2025-12-23 17:18:30.881+05:30	\N	\N	t	\N	\N	f	0	\N	42	\N	\N	\N	\N	\N
1fe8419d-7be4-4961-a020-eb68b96fc436	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000098	MAINTENANCE	\N	\N	\N	5ae848af-e1e2-4dc3-a14d-c8a5396b824e	Shower Head Leaking	Shower head is leaking from multiple points. Water spraying everywhere.	\N	ACKNOWLEDGED	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	13	\N	\N	\N	\N	\N
6ea8a7d7-ac8e-4147-9c02-61d261915473	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000099	MAINTENANCE	\N	\N	\N	9826254b-4208-479f-af75-c59a0d88babb	Garage Door Opener Not Working	Garage door opener remote is not working. Door cannot be opened remotely.	\N	ASSIGNED	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-24 06:10:30.882+05:30	\N	\N	\N	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	42	\N	\N	\N	\N	\N
68d0961b-502b-4604-8e54-8762c6c30842	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000100	MAINTENANCE	\N	\N	\N	aa1a0cdc-8202-4654-a28e-9bda086a3f84	Pool Pump Making Noise	Pool pump is making loud noise. May need maintenance or replacement.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-29 07:02:30.883+05:30	\N	\N	\N	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	6	\N	\N	\N	\N	\N
26b6ba40-8343-4c66-bff1-36564a39e42b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000101	MAINTENANCE	\N	\N	\N	61b1fbb4-305b-406d-8906-b48d47be9faf	Leaky Faucet in Kitchen	The kitchen faucet is leaking continuously. Water is dripping from the base and handle.	\N	NEW	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	82	\N	\N	\N	\N	\N
fc655b42-2179-459b-bec9-b05a3441a608	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000102	MAINTENANCE	\N	\N	\N	d4c313e9-9190-43d3-9280-4e19a3619f44	AC Not Cooling	Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.	\N	ACKNOWLEDGED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	40	\N	\N	\N	\N	\N
f3e6ae59-9477-407f-8b0c-434a311ad62a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000103	MAINTENANCE	\N	\N	\N	d2d93c15-e9a1-4bd4-bd69-67fd18be74c8	Broken Light Switch	Light switch in living room is not working. Need to replace the switch.	\N	NEW	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	77	\N	\N	\N	\N	\N
68389337-be46-424e-90e9-58078a7aa2ff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000104	MAINTENANCE	\N	\N	\N	aa1a0cdc-8202-4654-a28e-9bda086a3f84	Garbage Disposal Not Working	Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-02 16:32:30.886+05:30	\N	\N	2025-12-04 16:32:30.886+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	6	\N	\N	\N	\N	\N
23394129-835b-474a-ac6a-e8038f6eb086	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000105	MAINTENANCE	\N	\N	\N	d1c5678e-bd8c-4db0-a303-020d49396e0f	Window Won't Close Properly	Bedroom window cannot be closed completely. Security concern.	\N	ON_HOLD	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-08 18:12:30.887+05:30	\N	\N	2025-12-09 18:12:30.887+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	11	\N	\N	\N	\N	\N
1e28b01c-64f1-46b5-8df8-9f2d5a747bd3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000106	MAINTENANCE	\N	\N	\N	071618e8-48df-4397-bf58-13500b13b963	Heater Not Working	Heating system is not functioning. Very cold inside the villa.	\N	ASSIGNED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-29 01:21:30.887+05:30	\N	\N	\N	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	12	\N	\N	\N	\N	\N
b8916ece-b846-4bee-996a-2a8cb1021815	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000107	MAINTENANCE	\N	\N	\N	f4c87468-fa82-45fc-aa90-d3668f808a3b	Power Outlet Not Working	Power outlet in bedroom is not providing electricity. Checked with multiple devices.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-07 06:32:30.888+05:30	\N	\N	2025-12-09 06:32:30.888+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	69	\N	\N	\N	\N	\N
5f43f1dd-4ebb-43a8-a928-884c849f8346	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000108	MAINTENANCE	\N	\N	\N	120785d1-cb13-4721-9ef9-0bf3ab8f860f	Toilet Running Continuously	Toilet keeps running water even after flushing. Wasting water.	\N	ACKNOWLEDGED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	38	\N	\N	\N	\N	\N
208717fa-20e8-4b9d-9127-e83e1ff9494b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000109	MAINTENANCE	\N	\N	\N	38d853ee-2655-4675-94c3-32aa7c6710e9	Door Lock Malfunction	Main entrance door lock is not responding properly. Sometimes key gets stuck.	\N	NEW	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	66	\N	\N	\N	\N	\N
9d0a1dba-9420-4a69-a9c6-1410bbb6aca7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000110	MAINTENANCE	\N	\N	\N	38d853ee-2655-4675-94c3-32aa7c6710e9	Water Pressure Low	Water pressure in shower and kitchen sink is very low. Inconsistent flow.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-17 05:29:30.889+05:30	\N	\N	2025-12-17 05:29:30.889+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	66	\N	\N	\N	\N	\N
d6eb0d69-6608-40ac-bae2-02dfe0049115	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000111	MAINTENANCE	\N	\N	\N	79cdf8e8-d92d-4dd2-ac25-05633943c332	Ceiling Fan Making Noise	Ceiling fan in bedroom is making loud grinding noise. Needs inspection.	\N	ACKNOWLEDGED	LOW	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	61	\N	\N	\N	\N	\N
a779a6e4-ab4b-4db7-9d48-c39862b2e451	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000112	MAINTENANCE	\N	\N	\N	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	Garden Sprinkler Broken	Garden sprinkler system is not working. Some sprinklers are not turning on.	\N	ASSIGNED	LOW	\N	\N	\N	\N	e0d8cb45-3a1f-47b9-b1fb-ec0f317e4ed4	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-26 12:40:30.89+05:30	\N	\N	\N	Work in progress. Landscaping issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	50	\N	\N	\N	\N	\N
6aa36a8d-96c3-47ab-9dbb-2115794e0a4f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000113	MAINTENANCE	\N	\N	\N	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	Smoke Detector Beeping	Smoke detector is beeping continuously. Battery may need replacement.	\N	NEW	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	50	\N	\N	\N	\N	\N
89d90361-146b-4b2a-8a40-c918f8b253d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000114	MAINTENANCE	\N	\N	\N	61b1fbb4-305b-406d-8906-b48d47be9faf	Washing Machine Drain Issue	Washing machine drain is backing up. Water not draining properly.	\N	ASSIGNED	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-19 21:05:30.891+05:30	\N	\N	\N	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	82	\N	\N	\N	\N	\N
931274f2-1f1a-4388-ae2e-e6de742b2069	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000115	MAINTENANCE	\N	\N	\N	f8694dbb-a668-4fd2-9e16-0ab2f6c11dac	AC Filter Replacement Needed	AC filter is dirty and needs replacement. Air quality is poor.	\N	IN_PROGRESS	LOW	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-15 05:58:30.892+05:30	\N	\N	2025-12-17 05:58:30.892+05:30	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	73	\N	\N	\N	\N	\N
a81d0f25-22e7-4032-b5bb-e430957c729a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000116	MAINTENANCE	\N	\N	\N	b4968123-7908-457a-9e7c-2ae17c8fadaa	Broken Window Blind	Window blind in living room is broken. Cannot open or close properly.	\N	ON_HOLD	LOW	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-11 15:44:30.892+05:30	\N	\N	2025-12-12 15:44:30.892+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	20	\N	\N	\N	\N	\N
0f68a95a-0d8a-418d-9281-b759a1f0a387	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000117	MAINTENANCE	\N	\N	\N	5e21829a-b5e3-4498-bb83-e912d258e2b8	Refrigerator Not Cooling	Refrigerator is not maintaining cold temperature. Food is spoiling.	\N	COMPLETED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-14 10:13:30.893+05:30	\N	\N	2025-12-14 10:13:30.893+05:30	Work in progress. HVAC issue being addressed.	Issue resolved. HVAC work completed successfully.	2025-12-15 17:13:30.893+05:30	\N	\N	t	\N	\N	f	0	\N	48	\N	\N	\N	\N	\N
bf976497-a5ba-4750-b98d-a8ec07c4a6a7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000118	MAINTENANCE	\N	\N	\N	ac154839-ac39-455f-a2b1-9ba4efbcbbd5	Shower Head Leaking	Shower head is leaking from multiple points. Water spraying everywhere.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-29 06:21:30.894+05:30	\N	\N	2025-12-01 06:21:30.894+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	53	\N	\N	\N	\N	\N
8ac6b5be-9fee-4f17-81e7-5dbdad7a60a2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000119	MAINTENANCE	\N	\N	\N	9fc4ca33-d77a-452f-aa97-677485aa2285	Garage Door Opener Not Working	Garage door opener remote is not working. Door cannot be opened remotely.	\N	ACKNOWLEDGED	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	80	\N	\N	\N	\N	\N
b5926c78-521f-4c77-9033-4182b962c3a8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000120	MAINTENANCE	\N	\N	\N	9bd4b184-458f-4eab-9472-6578042407e0	Pool Pump Making Noise	Pool pump is making loud noise. May need maintenance or replacement.	\N	ON_HOLD	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-19 07:33:30.895+05:30	\N	\N	2025-12-19 07:33:30.895+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	17	\N	\N	\N	\N	\N
fc25e05c-13fa-4471-9308-b62ac137fbbb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000121	MAINTENANCE	\N	\N	\N	79cdf8e8-d92d-4dd2-ac25-05633943c332	Leaky Faucet in Kitchen	The kitchen faucet is leaking continuously. Water is dripping from the base and handle.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-20 14:23:30.896+05:30	\N	\N	2025-12-20 14:23:30.896+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	61	\N	\N	\N	\N	\N
feb85454-9b19-4ecb-8ca9-6010b634cd68	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000122	MAINTENANCE	\N	\N	\N	2df7ef09-1682-43c9-9c64-e479c86c1c1e	AC Not Cooling	Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.	\N	NEW	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	36	\N	\N	\N	\N	\N
483c0bd5-2142-4826-afff-6183f231fc87	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000123	MAINTENANCE	\N	\N	\N	d9361d85-2226-44be-b864-ad171091950c	Broken Light Switch	Light switch in living room is not working. Need to replace the switch.	\N	NEW	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	44	\N	\N	\N	\N	\N
1c150027-65a6-4c91-8f5f-44071bd82a58	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000124	MAINTENANCE	\N	\N	\N	ec44affc-f5ff-40ef-a3de-b8f303fee488	Garbage Disposal Not Working	Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-19 21:02:30.898+05:30	\N	\N	2025-12-20 21:02:30.898+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	54	\N	\N	\N	\N	\N
236e5cdf-677c-47f3-8f93-967b7e56b0fc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000125	MAINTENANCE	\N	\N	\N	53bde808-7662-4bfc-a407-54fd1b83b4f6	Window Won't Close Properly	Bedroom window cannot be closed completely. Security concern.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-01 11:24:30.898+05:30	\N	\N	2025-12-02 11:24:30.898+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	49	\N	\N	\N	\N	\N
cc71cc40-a906-49a2-93bf-a3387a19b1fe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000126	MAINTENANCE	\N	\N	\N	4cb39fa4-be14-4a89-9fae-f88ea5406111	Heater Not Working	Heating system is not functioning. Very cold inside the villa.	\N	NEW	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	37	\N	\N	\N	\N	\N
5f0d98bc-c50e-489e-9231-6afe16b6ca6f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000127	MAINTENANCE	\N	\N	\N	61e3614b-3b90-47a9-baf7-ecf8e7a6b96c	Power Outlet Not Working	Power outlet in bedroom is not providing electricity. Checked with multiple devices.	\N	ACKNOWLEDGED	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	35	\N	\N	\N	\N	\N
7fff1180-17da-442a-88a6-f44dae350d58	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000128	MAINTENANCE	\N	\N	\N	5b91137f-8c0a-403f-8bd3-f26ba765e8a3	Toilet Running Continuously	Toilet keeps running water even after flushing. Wasting water.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-13 06:07:30.9+05:30	\N	\N	2025-12-15 06:07:30.9+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	67	\N	\N	\N	\N	\N
7e98fd5a-77ba-44e0-8901-1da35073c345	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000129	MAINTENANCE	\N	\N	\N	71e291b7-f092-40b6-9819-8fc848682e6a	Door Lock Malfunction	Main entrance door lock is not responding properly. Sometimes key gets stuck.	\N	ON_HOLD	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-14 14:09:30.9+05:30	\N	\N	2025-12-15 14:09:30.9+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	8	\N	\N	\N	\N	\N
9407bde7-9de3-4826-a260-30f783cbc5b7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000130	MAINTENANCE	\N	\N	\N	93d899ce-d497-4f95-82b2-fe293db75dc5	Water Pressure Low	Water pressure in shower and kitchen sink is very low. Inconsistent flow.	\N	ASSIGNED	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-15 05:48:30.901+05:30	\N	\N	\N	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	41	\N	\N	\N	\N	\N
5030c55e-5f75-4a1f-8a85-6d1a9e3e1a4b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000131	MAINTENANCE	\N	\N	\N	407f8619-e786-4515-8bbe-1676e3bbc361	Ceiling Fan Making Noise	Ceiling fan in bedroom is making loud grinding noise. Needs inspection.	\N	ON_HOLD	LOW	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-26 06:29:30.901+05:30	\N	\N	2025-11-28 06:29:30.901+05:30	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	22	\N	\N	\N	\N	\N
e4c02c7d-6f11-4f80-bfb1-d6d5afae6c5a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000132	MAINTENANCE	\N	\N	\N	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	Garden Sprinkler Broken	Garden sprinkler system is not working. Some sprinklers are not turning on.	\N	IN_PROGRESS	LOW	\N	\N	\N	\N	e0d8cb45-3a1f-47b9-b1fb-ec0f317e4ed4	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-18 09:30:30.902+05:30	\N	\N	2025-12-18 09:30:30.902+05:30	Work in progress. Landscaping issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	33	\N	\N	\N	\N	\N
37c0bc43-84ba-4d95-8a02-e53bcacc1fac	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000133	MAINTENANCE	\N	\N	\N	8bcb8775-4b58-4050-85f8-885a9b8b0fe4	Smoke Detector Beeping	Smoke detector is beeping continuously. Battery may need replacement.	\N	ASSIGNED	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-22 01:42:30.903+05:30	\N	\N	\N	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	19	\N	\N	\N	\N	\N
66a653ee-0761-4996-9c99-ee1293d9c38e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000134	MAINTENANCE	\N	\N	\N	12ad4336-b729-4548-8029-c4282d7fb413	Washing Machine Drain Issue	Washing machine drain is backing up. Water not draining properly.	\N	IN_PROGRESS	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-07 16:30:30.903+05:30	\N	\N	2025-12-09 16:30:30.903+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	62	\N	\N	\N	\N	\N
1b047d97-85bd-4e7a-965f-f633812b4b90	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000135	MAINTENANCE	\N	\N	\N	3a55a2a5-5792-4cac-8d1a-f89f2636b489	AC Filter Replacement Needed	AC filter is dirty and needs replacement. Air quality is poor.	\N	ON_HOLD	LOW	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-27 21:59:30.904+05:30	\N	\N	2025-11-28 21:59:30.904+05:30	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	56	\N	\N	\N	\N	\N
690dd591-946e-40d6-a86d-e53ab0e4c381	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000136	MAINTENANCE	\N	\N	\N	79cdf8e8-d92d-4dd2-ac25-05633943c332	Broken Window Blind	Window blind in living room is broken. Cannot open or close properly.	\N	ON_HOLD	LOW	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-22 20:53:30.904+05:30	\N	\N	2025-12-22 20:53:30.904+05:30	Work in progress. General Maintenance issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	61	\N	\N	\N	\N	\N
bedb9461-fc70-49d0-b05f-7c9c3629f37b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000137	MAINTENANCE	\N	\N	\N	61b1fbb4-305b-406d-8906-b48d47be9faf	Refrigerator Not Cooling	Refrigerator is not maintaining cold temperature. Food is spoiling.	\N	ASSIGNED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-21 07:06:30.905+05:30	\N	\N	\N	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	82	\N	\N	\N	\N	\N
33e7df9f-f7a1-43a2-b2cc-42a271858a28	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000138	MAINTENANCE	\N	\N	\N	53e744ac-828b-41ed-b12a-34f7829c1e38	Shower Head Leaking	Shower head is leaking from multiple points. Water spraying everywhere.	\N	ON_HOLD	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-27 02:38:30.905+05:30	\N	\N	2025-11-29 02:38:30.905+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	55	\N	\N	\N	\N	\N
df1168d7-0ed2-445e-939a-3e2dce9e53d8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000139	MAINTENANCE	\N	\N	\N	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	Garage Door Opener Not Working	Garage door opener remote is not working. Door cannot be opened remotely.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-05 06:32:30.906+05:30	\N	\N	2025-12-05 06:32:30.906+05:30	Work in progress. General Maintenance issue being addressed.	Issue resolved. General Maintenance work completed successfully.	2025-12-09 11:32:30.906+05:30	\N	\N	t	\N	\N	f	0	\N	79	\N	\N	\N	\N	\N
760a6445-68be-41d6-82b4-1adf05a2b0bb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000140	MAINTENANCE	\N	\N	\N	98c7399e-0621-457a-b93b-d8eeaaac4630	Pool Pump Making Noise	Pool pump is making loud noise. May need maintenance or replacement.	\N	NEW	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	59	\N	\N	\N	\N	\N
fe2c5289-ac68-4fd6-9904-8cfbaffbe9e3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000141	MAINTENANCE	\N	\N	\N	8eb63fe5-7d76-48a0-9456-36d698f469ed	Leaky Faucet in Kitchen	The kitchen faucet is leaking continuously. Water is dripping from the base and handle.	\N	ON_HOLD	HIGH	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-21 10:24:30.907+05:30	\N	\N	2025-12-23 10:24:30.907+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	16	\N	\N	\N	\N	\N
c24e31e5-6c8b-43ff-ac28-08ba1832e18b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000142	MAINTENANCE	\N	\N	\N	676ad3ae-87fa-4a38-8bf7-2debba141c77	AC Not Cooling	Air conditioning unit is not cooling properly. Temperature remains high despite setting it to lowest.	\N	ASSIGNED	URGENT	\N	\N	\N	\N	9cb540b9-3bfc-4912-8293-293ff2a2c279	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-06 18:04:30.908+05:30	\N	\N	\N	Work in progress. HVAC issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	70	\N	\N	\N	\N	\N
010e69b7-e264-4d7b-91dc-ea5e405bbfca	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000143	MAINTENANCE	\N	\N	\N	b18189ca-de52-4473-abc4-4e019eb74fef	Broken Light Switch	Light switch in living room is not working. Need to replace the switch.	\N	ASSIGNED	MEDIUM	\N	\N	\N	\N	aab5b8b8-dad3-498c-ae3f-3e4fe73b01fe	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-18 19:21:30.908+05:30	\N	\N	\N	Work in progress. Electrical issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	27	\N	\N	\N	\N	\N
726af69c-4df6-468a-adb8-7eaed6b39a2c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000144	MAINTENANCE	\N	\N	\N	071618e8-48df-4397-bf58-13500b13b963	Garbage Disposal Not Working	Kitchen garbage disposal makes noise but does not grind. May need repair or replacement.	\N	COMPLETED	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-16 09:11:30.909+05:30	\N	\N	2025-12-18 09:11:30.909+05:30	Work in progress. Plumbing issue being addressed.	Issue resolved. Plumbing work completed successfully.	2025-12-21 17:11:30.909+05:30	\N	\N	t	\N	\N	f	0	\N	12	\N	\N	\N	\N	\N
c39b6048-33b7-42f7-bdd6-589b7fe61acd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000149	MAINTENANCE	\N	\N	\N	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	Door Lock Malfunction	Main entrance door lock is not responding properly. Sometimes key gets stuck.	\N	COMPLETED	HIGH	\N	\N	\N	\N	5d4eb034-2b0f-4d9d-af70-cb9ddc3c3127	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-12-05 16:08:30.912+05:30	\N	\N	2025-12-07 16:08:30.912+05:30	Work in progress. General Maintenance issue being addressed.	Issue resolved. General Maintenance work completed successfully.	2025-12-11 22:08:30.912+05:30	\N	\N	f	\N	\N	f	0	\N	79	\N	\N	\N	\N	\N
96bf4f85-c7ed-4d32-9f2c-388ea3a156f3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TKT-000150	MAINTENANCE	\N	\N	\N	93d899ce-d497-4f95-82b2-fe293db75dc5	Water Pressure Low	Water pressure in shower and kitchen sink is very low. Inconsistent flow.	\N	IN_PROGRESS	MEDIUM	\N	\N	\N	\N	e3a5956b-c8f3-4ba4-a7a3-cf5a1112ad01	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	2025-11-24 16:05:30.912+05:30	\N	\N	2025-11-25 16:05:30.912+05:30	Work in progress. Plumbing issue being addressed.	\N	\N	\N	\N	f	\N	\N	f	0	\N	41	\N	\N	\N	\N	\N
74b948e0-74b4-48d9-b0bd-45532750eaa9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:44:53.840159	2025-12-23 15:44:53.840159	TKT-2025-0001	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Broken Chair in Hallway	A chair located in the hallway is damaged and requires repair or replacement.	Hallway	NEW	LOW	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	85	\N	\N	\N	\N	\N
6741b8c0-317c-4746-8ef3-3c89028ee0da	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:52:12.944119	2025-12-24 22:56:23.720276	TKT-2025-0004	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	No Electrical Power in Kitchen	Complete loss of electrical power detected in the kitchen area.	Kitchen	COMPLETED	HIGH	\N	\N	\N	2025-12-24T23:00:00.000/2025-12-24T12:30:00.000	\N	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-24 22:53:02.533+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-24 22:52:47.369+05:30	\N	Fixed	\N	2025-12-24 22:56:01.023+05:30	2025-12-24 22:56:23.714+05:30	\N	t	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
9dc8bae4-aad4-494d-8183-43b4045abb45	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:09:24.247042	2025-12-24 18:18:49.100556	TKT-2025-0003	MAINTENANCE	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87	Broken chair requires repair or replacement	A chair is broken and requires repair or replacement. Please assess the damage.	\N	ASSIGNED	MEDIUM	9f4a0f9c-6442-449c-a94e-c4e2467e7a47	\N	\N	2025-12-24T12:08:00.000/2025-12-24T18:00:00.000	\N	\N	\N	be3cf16a-1466-4065-a1b0-47ff590bc0b4	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-24 18:18:14.021+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-24 18:01:11.907+05:30	\N	New notes	\N	\N	\N	\N	f	\N	\N	f	0	\N	84	\N	\N	\N	\N	\N
6d35f6db-4ebc-4a21-992d-bc17bd67f715	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:24:18.966746	2025-12-26 15:24:18.966746	TKT-2025-0006	MAINTENANCE	\N	\N	\N	44142ebb-779d-4e83-b0a2-3db691e389ff	Broken Chair Requires Repair/Replacement	A chair is broken and requires repair or replacement. The specific nature of the damage needs assessment.	\N	NEW	MEDIUM	\N	\N	\N	2025-12-26T15:24:00.000/2025-12-26T16:24:00.000	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	5011	\N	\N	\N	\N	\N
b214eadc-297e-4e34-beef-c3e177c4fd3f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:44:22.496592	2025-12-26 10:54:59.635918	TKT-2025-0005	MAINTENANCE	\N	\N	\N	44142ebb-779d-4e83-b0a2-3db691e389ff	Water Leak Detected from Kitchen Pipe	A water leak has been reported originating from a pipe located in the kitchen area. Immediate inspection and repair are required to prevent potential water damage.	Kitchen	COMPLETED	HIGH	\N	\N	\N	2025-12-27T10:43:00.000/2025-12-27T12:43:00.000	\N	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 10:49:12.824+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 10:48:47.793+05:30	\N	Fixed	\N	2025-12-26 10:53:06.725+05:30	2025-12-26 10:54:59.634+05:30	\N	t	\N	\N	f	0	\N	5011	\N	\N	\N	\N	\N
107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:38:36.25546	2025-12-26 16:02:47.402879	TKT-2025-0007	MAINTENANCE	\N	\N	\N	44142ebb-779d-4e83-b0a2-3db691e389ff	Broken Chair in Hallway	A chair located in the main hall is broken and requires repair or replacement.	Hall	IN_PROGRESS	LOW	\N	\N	\N	2025-12-26T15:38:00.000/2025-12-26T16:38:00.000	\N	\N	\N	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 15:44:40.217+05:30	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	2025-12-26 15:44:35.121+05:30	\N	\N	\N	\N	\N	\N	f	\N	\N	f	0	\N	5011	\N	\N	\N	\N	\N
\.


--
-- TOC entry 4380 (class 0 OID 65517)
-- Dependencies: 218
-- Data for Name: notification_audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification_audit_logs (id, company_id, created_at, updated_at, "eventType", severity, recipient_user_id, event_payload, metadata) FROM stdin;
0edd284d-4df2-43c8-b52d-9db5dd34d727	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:51:50.266762	2025-12-31 09:51:50.266762	test_notification	info	44142ebb-779d-4e83-b0a2-3db691e389ff	{"title": "Test Push Notification", "message": "Hello Vivek! This is a test push notification from the TENX system. Time: 12/31/2025, 9:51:50 AM", "recipient": {"email": "vivek.ellappan@helixsense.com", "lastName": "Ellappan", "firstName": "Vivek"}}	{"channels": ["push", "in_app"]}
0ba6a10f-bb62-451e-85dc-e2af789ae42a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:54:27.574938	2025-12-31 09:54:27.574938	test_notification	info	44142ebb-779d-4e83-b0a2-3db691e389ff	{"title": "Test Push Notification", "message": "Hello Vivek! This is a test push notification from the TENX system. Time: 12/31/2025, 9:54:27 AM", "recipient": {"email": "vivek.ellappan@helixsense.com", "lastName": "Ellappan", "firstName": "Vivek"}}	{"channels": ["push", "in_app"]}
671d1d80-ba01-4b05-965b-3c12680684ae	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:03:53.273663	2025-12-31 10:03:53.273663	ticket_created	info	44142ebb-779d-4e83-b0a2-3db691e389ff	{"title": "New Ticket: TKT-2025-0016", "message": "Vivek Ellappan created a Urgent priority ticket: Fire reported in the hall area (Villa 84)", "priority": "Urgent", "ticketId": "553788fb-7388-434c-b04c-be87691d4ecc", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2025-0016"}	{"channels": ["push", "in_app"]}
4e8bdc1f-0142-408f-8999-09b43402b4fe	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.345043	2026-01-01 07:41:55.345043	tenant_ticket_ticket_created	info	95791439-c679-4dec-98cf-1eccedd65a87	{"title": "Ticket Created: TKT-2026-0001", "message": "Your ticket \\"Water Pipe Leaking\\" has been created successfully.", "ticketId": "04be10c5-23c9-4299-befd-94632df7e182", "ticketNumber": "TKT-2026-0001"}	{"channels": ["push", "in_app"]}
985344ae-d051-4664-984b-0c9fdab01fda	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.347551	2026-01-01 07:41:55.347551	ticket_created	info	44142ebb-779d-4e83-b0a2-3db691e389ff	{"title": "New Ticket: TKT-2026-0001", "message": "Vivek Ellappan created a High priority ticket: Water Pipe Leaking (Villa 84)", "priority": "High", "ticketId": "04be10c5-23c9-4299-befd-94632df7e182", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2026-0001"}	{"channels": ["push", "in_app"]}
241b0775-af2c-4bea-b71d-159f3412f1f0	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.349049	2026-01-01 07:51:22.349049	tenant_ticket_ticket_created	info	95791439-c679-4dec-98cf-1eccedd65a87	{"title": "Ticket Created: TKT-2026-0002", "message": "Your ticket \\"AC Unit Malfunction in Bedroom\\" has been created successfully.", "ticketId": "b3167e24-7241-4858-b78d-75affe56707f", "ticketNumber": "TKT-2026-0002"}	{"channels": ["push", "in_app"]}
230f0c23-cccf-4713-b9b4-8e0e5b66b722	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.355707	2026-01-01 07:51:22.355707	ticket_created	info	44142ebb-779d-4e83-b0a2-3db691e389ff	{"title": "New Ticket: TKT-2026-0002", "message": "Vivek Ellappan created a Medium priority ticket: AC Unit Malfunction in Bedroom (Villa 84)", "priority": "Medium", "ticketId": "b3167e24-7241-4858-b78d-75affe56707f", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2026-0002"}	{"channels": ["push", "in_app"]}
43f6067f-ad21-437f-8b3f-8343008f0f02	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.74702	2026-01-01 07:57:47.74702	tenant_ticket_ticket_created	info	95791439-c679-4dec-98cf-1eccedd65a87	{"title": "Ticket Created: TKT-2026-0003", "message": "Your ticket \\"Broken Water Pipe in Hallway\\" has been created successfully.", "ticketId": "518a030e-4357-4aaa-b019-03657ca5e722", "ticketNumber": "TKT-2026-0003"}	{"channels": ["push", "in_app"]}
9528ee1e-8d2f-457b-b560-f45fb509e35e	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.751485	2026-01-01 07:57:47.751485	ticket_created	info	44142ebb-779d-4e83-b0a2-3db691e389ff	{"title": "New Ticket: TKT-2026-0003", "message": "Vivek Ellappan created a High priority ticket: Broken Water Pipe in Hallway (Villa 84)", "priority": "High", "ticketId": "518a030e-4357-4aaa-b019-03657ca5e722", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2026-0003"}	{"channels": ["push", "in_app"]}
408d582b-77b3-421e-a194-7b803f9fd558	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.145608	2026-01-01 08:04:27.145608	tenant_ticket_ticket_created	info	95791439-c679-4dec-98cf-1eccedd65a87	{"title": "Ticket Created: TKT-2026-0004", "message": "Your ticket \\"Broken Pipe Requiring Immediate Repair\\" has been created successfully.", "ticketId": "db1f2cb5-59c4-4e04-a340-ac894fc68772", "ticketNumber": "TKT-2026-0004"}	{"channels": ["push", "in_app"]}
fb912b54-4f12-48c3-a04a-9d0accc1c58f	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.15088	2026-01-01 08:04:27.15088	ticket_created	info	44142ebb-779d-4e83-b0a2-3db691e389ff	{"title": "New Ticket: TKT-2026-0004", "message": "Vivek Ellappan created a High priority ticket: Broken Pipe Requiring Immediate Repair (Villa 84)", "priority": "High", "ticketId": "db1f2cb5-59c4-4e04-a340-ac894fc68772", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2026-0004"}	{"channels": ["push", "in_app"]}
d2b6c0c0-7fb4-4797-bbd7-3775c57ff0b5	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:29:57.294676	2026-01-01 08:29:57.294676	tenant_ticket_status_changed	info	95791439-c679-4dec-98cf-1eccedd65a87	{"notes": "Ticket cancelled", "title": "Status Updated: TKT-2026-0004", "message": "Your ticket status has been updated to: Cancelled - Ticket cancelled", "ticketId": "db1f2cb5-59c4-4e04-a340-ac894fc68772", "newStatus": "CANCELLED", "ticketNumber": "TKT-2026-0004", "previousStatus": "NEW"}	{"channels": ["push", "in_app"]}
\.


--
-- TOC entry 4377 (class 0 OID 65480)
-- Dependencies: 215
-- Data for Name: notification_deliveries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification_deliveries (id, company_id, created_at, updated_at, notification_id, channel, status, attempt_count, last_error, "notificationId") FROM stdin;
39910a55-ebf8-4e4b-b6d4-8101f69c11f6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:51:50.269794	2025-12-31 09:51:50.269794	569712d6-b705-4b42-954d-04887a792ece	push	failed	3	Firebase Admin not initialized. Please configure FIREBASE_* environment variables.	\N
18e5543f-e6c5-412f-8162-da00f9d47674	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:51:50.273652	2025-12-31 09:51:50.273652	569712d6-b705-4b42-954d-04887a792ece	in_app	success	0	\N	\N
ae57c6d4-dcfa-46a3-a55d-bb4df998eea7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:54:27.578467	2025-12-31 09:54:27.578467	25379015-31cf-42a5-859d-4bd78c37c9cd	push	failed	3	No active FCM tokens found for user	\N
07a6be80-df5d-42bc-ad8b-19f162a9790d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:54:27.580126	2025-12-31 09:54:27.580126	25379015-31cf-42a5-859d-4bd78c37c9cd	in_app	success	0	\N	\N
f10f5b56-cae8-4481-bd7c-a70be6465d28	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:03:53.274731	2025-12-31 10:03:53.274731	992f1052-918f-4592-8bf5-20da87aa4c9c	push	failed	3	User ID is required for push notifications	\N
e548a175-5e03-4287-a0b0-bf08c6e98660	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:03:53.276117	2025-12-31 10:03:53.276117	992f1052-918f-4592-8bf5-20da87aa4c9c	in_app	success	0	\N	\N
4dc9938a-8d02-44cb-b919-5c5374d38dc6	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.348941	2026-01-01 07:41:55.348941	86db21e8-1451-4d50-8765-5b65fccc38dc	push	failed	3	User ID is required for push notifications	\N
bd0dee3d-b264-4cbb-9fd8-e63c023f3742	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.34901	2026-01-01 07:41:55.34901	0e7243cf-74ce-488f-b5cc-e3ae9680635c	push	failed	3	User ID is required for push notifications	\N
e0dae2d6-d76f-4ee4-8eab-0bf3b0021308	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.351733	2026-01-01 07:41:55.351733	86db21e8-1451-4d50-8765-5b65fccc38dc	in_app	success	0	\N	\N
db187b4e-6c19-4287-9ada-0aac87646500	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.351791	2026-01-01 07:41:55.351791	0e7243cf-74ce-488f-b5cc-e3ae9680635c	in_app	success	0	\N	\N
1df25bb9-02d9-4ca1-96ee-04506deecbe3	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.350995	2026-01-01 07:51:22.350995	9bfb8e7d-9374-448a-ac22-c3f20c33d03b	push	failed	3	User ID is required for push notifications	\N
8a18a76f-1cae-443d-818a-e280d93107c6	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.352902	2026-01-01 07:51:22.352902	9bfb8e7d-9374-448a-ac22-c3f20c33d03b	in_app	success	0	\N	\N
3b43bcb6-643f-48fc-b9d8-a60d8efa7e30	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.356282	2026-01-01 07:51:22.356282	201f6a06-babb-4c9c-9e93-65d5afe4bb8e	push	failed	3	User ID is required for push notifications	\N
1dff3128-5dae-4af0-8005-5b4e8bf05dfd	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.356943	2026-01-01 07:51:22.356943	201f6a06-babb-4c9c-9e93-65d5afe4bb8e	in_app	success	0	\N	\N
3ee98082-e993-48bc-90cd-d8c6e6342847	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.748218	2026-01-01 07:57:47.748218	ff4bbf51-23fd-43c4-a81b-09c922b6e547	push	failed	3	User ID is required for push notifications	\N
b3d9cfa2-4bae-4e12-9779-2f772a759230	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.74912	2026-01-01 07:57:47.74912	ff4bbf51-23fd-43c4-a81b-09c922b6e547	in_app	success	0	\N	\N
c988a553-f1a3-487c-94a5-c3d37df253d2	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.752035	2026-01-01 07:57:47.752035	1088fa47-e263-4fb3-976b-936e4dc9ddc6	push	failed	3	User ID is required for push notifications	\N
d4f1c742-8116-45a7-aca7-7f4f14f7d759	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.752747	2026-01-01 07:57:47.752747	1088fa47-e263-4fb3-976b-936e4dc9ddc6	in_app	success	0	\N	\N
28f01aca-d5b4-4dc1-8c5e-475fa8701560	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.147059	2026-01-01 08:04:27.147059	e94f2c5a-1535-404e-a674-170737dc4dbe	push	failed	3	User ID is required for push notifications	\N
8c0a8635-90b3-42c1-a23a-6e49efff0d47	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.148742	2026-01-01 08:04:27.148742	e94f2c5a-1535-404e-a674-170737dc4dbe	in_app	success	0	\N	\N
aaf2ff97-4a42-41d2-a111-7a98b57187d7	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.152153	2026-01-01 08:04:27.152153	6efde7c6-1286-46dd-b5f7-69332964bb23	push	failed	3	User ID is required for push notifications	\N
d395a41e-a0c0-458e-a5fe-9527f52896f0	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.152993	2026-01-01 08:04:27.152993	6efde7c6-1286-46dd-b5f7-69332964bb23	in_app	success	0	\N	\N
d731c4cd-c9a2-411e-ae9a-7ed2e52eb420	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:29:57.295987	2026-01-01 08:29:57.295987	39db459f-55fb-4fa2-b1e3-5e65cc99462c	push	failed	3	User ID is required for push notifications	\N
1af008f8-dd59-4e17-83af-79cfd2887c10	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:29:57.297257	2026-01-01 08:29:57.297257	39db459f-55fb-4fa2-b1e3-5e65cc99462c	in_app	success	0	\N	\N
\.


--
-- TOC entry 4379 (class 0 OID 65506)
-- Dependencies: 217
-- Data for Name: notification_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification_templates (id, company_id, created_at, updated_at, code, channel, subject, body, default_variables) FROM stdin;
81235ef4-d189-44c6-9580-9e6dc43151a9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:51:50.25078	2025-12-31 09:51:50.25078	test_push_notification	push	Test Notification	{{message}}	{"message": "This is a test push notification"}
e7f29a23-7690-4cfe-82ee-3f8d7e6ed3b4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:51:50.260531	2025-12-31 09:51:50.260531	test_push_notification	in_app	\N	{{message}}	{"message": "This is a test notification"}
8713711a-1fd3-45b9-894e-f7e2a7b13f6e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:02:04.054626	2025-12-31 10:02:04.054626	ticket_created_push	push	New Ticket Created	{{message}}	{"message": "A new ticket has been created"}
c5d5dc90-dbae-441b-b126-0b6a3e0ae352	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:02:04.057148	2025-12-31 10:02:04.057148	ticket_created_push	in_app	\N	{{message}}	{"message": "A new ticket has been created"}
1de55594-4a9b-43b1-9c77-29f88e90964b	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.326923	2026-01-01 07:41:55.326923	tenant_ticket_ticket_created	push	Ticket Update	{{message}}	{"message": "Your ticket has been updated"}
7fd98199-c60c-47c8-8405-c34672d465d4	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.334812	2026-01-01 07:41:55.334812	tenant_ticket_ticket_created	in_app	\N	{{message}}	{"message": "Your ticket has been updated"}
576ff3eb-4e44-4c57-ad6a-64a9fe27f133	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:29:57.288031	2026-01-01 08:29:57.288031	tenant_ticket_status_changed	push	Ticket Update	{{message}}	{"message": "Your ticket has been updated"}
feffb969-e71e-4066-a85c-f68ab00d29ef	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:29:57.290883	2026-01-01 08:29:57.290883	tenant_ticket_status_changed	in_app	\N	{{message}}	{"message": "Your ticket has been updated"}
\.


--
-- TOC entry 4378 (class 0 OID 65493)
-- Dependencies: 216
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, company_id, created_at, updated_at, recipient_user_id, type, severity, title, message, payload, is_read, read_at, channels) FROM stdin;
25379015-31cf-42a5-859d-4bd78c37c9cd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:54:27.566245	2025-12-31 09:57:45.415272	44142ebb-779d-4e83-b0a2-3db691e389ff	test_notification	info	Test Push Notification	Hello Vivek! This is a test push notification from the TENX system. Time: 12/31/2025, 9:54:27 AM	{"title": "Test Push Notification", "message": "Hello Vivek! This is a test push notification from the TENX system. Time: 12/31/2025, 9:54:27 AM", "recipient": {"email": "vivek.ellappan@helixsense.com", "lastName": "Ellappan", "firstName": "Vivek"}}	t	2025-12-31 09:57:45.396+05:30	{push,in_app}
569712d6-b705-4b42-954d-04887a792ece	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:51:50.262671	2025-12-31 09:57:45.516738	44142ebb-779d-4e83-b0a2-3db691e389ff	test_notification	info	Test Push Notification	Hello Vivek! This is a test push notification from the TENX system. Time: 12/31/2025, 9:51:50 AM	{"title": "Test Push Notification", "message": "Hello Vivek! This is a test push notification from the TENX system. Time: 12/31/2025, 9:51:50 AM", "recipient": {"email": "vivek.ellappan@helixsense.com", "lastName": "Ellappan", "firstName": "Vivek"}}	t	2025-12-31 09:57:45.516+05:30	{push,in_app}
992f1052-918f-4592-8bf5-20da87aa4c9c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:03:53.268877	2025-12-31 10:03:53.268877	44142ebb-779d-4e83-b0a2-3db691e389ff	ticket_created	info	New Ticket: TKT-2025-0016	Vivek Ellappan created a Urgent priority ticket: Fire reported in the hall area (Villa 84)	{"title": "New Ticket: TKT-2025-0016", "message": "Vivek Ellappan created a Urgent priority ticket: Fire reported in the hall area (Villa 84)", "priority": "Urgent", "ticketId": "553788fb-7388-434c-b04c-be87691d4ecc", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2025-0016"}	f	\N	{push,in_app}
0e7243cf-74ce-488f-b5cc-e3ae9680635c	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.339654	2026-01-01 07:41:55.339654	44142ebb-779d-4e83-b0a2-3db691e389ff	ticket_created	info	New Ticket: TKT-2026-0001	Vivek Ellappan created a High priority ticket: Water Pipe Leaking (Villa 84)	{"title": "New Ticket: TKT-2026-0001", "message": "Vivek Ellappan created a High priority ticket: Water Pipe Leaking (Villa 84)", "priority": "High", "ticketId": "04be10c5-23c9-4299-befd-94632df7e182", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2026-0001"}	f	\N	{push,in_app}
201f6a06-babb-4c9c-9e93-65d5afe4bb8e	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.35393	2026-01-01 07:51:22.35393	44142ebb-779d-4e83-b0a2-3db691e389ff	ticket_created	info	New Ticket: TKT-2026-0002	Vivek Ellappan created a Medium priority ticket: AC Unit Malfunction in Bedroom (Villa 84)	{"title": "New Ticket: TKT-2026-0002", "message": "Vivek Ellappan created a Medium priority ticket: AC Unit Malfunction in Bedroom (Villa 84)", "priority": "Medium", "ticketId": "b3167e24-7241-4858-b78d-75affe56707f", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2026-0002"}	f	\N	{push,in_app}
86db21e8-1451-4d50-8765-5b65fccc38dc	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.338398	2026-01-01 07:53:31.29619	95791439-c679-4dec-98cf-1eccedd65a87	tenant_ticket_ticket_created	info	Ticket Created: TKT-2026-0001	Your ticket "Water Pipe Leaking" has been created successfully.	{"title": "Ticket Created: TKT-2026-0001", "message": "Your ticket \\"Water Pipe Leaking\\" has been created successfully.", "ticketId": "04be10c5-23c9-4299-befd-94632df7e182", "ticketNumber": "TKT-2026-0001"}	t	2026-01-01 07:53:31.292+05:30	{push,in_app}
9bfb8e7d-9374-448a-ac22-c3f20c33d03b	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.344459	2026-01-01 07:53:31.29619	95791439-c679-4dec-98cf-1eccedd65a87	tenant_ticket_ticket_created	info	Ticket Created: TKT-2026-0002	Your ticket "AC Unit Malfunction in Bedroom" has been created successfully.	{"title": "Ticket Created: TKT-2026-0002", "message": "Your ticket \\"AC Unit Malfunction in Bedroom\\" has been created successfully.", "ticketId": "b3167e24-7241-4858-b78d-75affe56707f", "ticketNumber": "TKT-2026-0002"}	t	2026-01-01 07:53:31.292+05:30	{push,in_app}
ff4bbf51-23fd-43c4-a81b-09c922b6e547	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.742886	2026-01-01 07:57:47.742886	95791439-c679-4dec-98cf-1eccedd65a87	tenant_ticket_ticket_created	info	Ticket Created: TKT-2026-0003	Your ticket "Broken Water Pipe in Hallway" has been created successfully.	{"title": "Ticket Created: TKT-2026-0003", "message": "Your ticket \\"Broken Water Pipe in Hallway\\" has been created successfully.", "ticketId": "518a030e-4357-4aaa-b019-03657ca5e722", "ticketNumber": "TKT-2026-0003"}	f	\N	{push,in_app}
1088fa47-e263-4fb3-976b-936e4dc9ddc6	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.749677	2026-01-01 07:57:47.749677	44142ebb-779d-4e83-b0a2-3db691e389ff	ticket_created	info	New Ticket: TKT-2026-0003	Vivek Ellappan created a High priority ticket: Broken Water Pipe in Hallway (Villa 84)	{"title": "New Ticket: TKT-2026-0003", "message": "Vivek Ellappan created a High priority ticket: Broken Water Pipe in Hallway (Villa 84)", "priority": "High", "ticketId": "518a030e-4357-4aaa-b019-03657ca5e722", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2026-0003"}	f	\N	{push,in_app}
6efde7c6-1286-46dd-b5f7-69332964bb23	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.148853	2026-01-01 08:04:27.148853	44142ebb-779d-4e83-b0a2-3db691e389ff	ticket_created	info	New Ticket: TKT-2026-0004	Vivek Ellappan created a High priority ticket: Broken Pipe Requiring Immediate Repair (Villa 84)	{"title": "New Ticket: TKT-2026-0004", "message": "Vivek Ellappan created a High priority ticket: Broken Pipe Requiring Immediate Repair (Villa 84)", "priority": "High", "ticketId": "db1f2cb5-59c4-4e04-a340-ac894fc68772", "creatorName": "Vivek Ellappan", "villaNumber": "84", "ticketNumber": "TKT-2026-0004"}	f	\N	{push,in_app}
e94f2c5a-1535-404e-a674-170737dc4dbe	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.141678	2026-01-01 08:10:54.261521	95791439-c679-4dec-98cf-1eccedd65a87	tenant_ticket_ticket_created	info	Ticket Created: TKT-2026-0004	Your ticket "Broken Pipe Requiring Immediate Repair" has been created successfully.	{"title": "Ticket Created: TKT-2026-0004", "message": "Your ticket \\"Broken Pipe Requiring Immediate Repair\\" has been created successfully.", "ticketId": "db1f2cb5-59c4-4e04-a340-ac894fc68772", "ticketNumber": "TKT-2026-0004"}	t	2026-01-01 08:10:54.237+05:30	{push,in_app}
39db459f-55fb-4fa2-b1e3-5e65cc99462c	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:29:57.292172	2026-01-01 08:29:57.292172	95791439-c679-4dec-98cf-1eccedd65a87	tenant_ticket_status_changed	info	Status Updated: TKT-2026-0004	Your ticket status has been updated to: Cancelled - Ticket cancelled	{"notes": "Ticket cancelled", "title": "Status Updated: TKT-2026-0004", "message": "Your ticket status has been updated to: Cancelled - Ticket cancelled", "ticketId": "db1f2cb5-59c4-4e04-a340-ac894fc68772", "newStatus": "CANCELLED", "ticketNumber": "TKT-2026-0004", "previousStatus": "NEW"}	f	\N	{push,in_app}
\.


--
-- TOC entry 4402 (class 0 OID 66064)
-- Dependencies: 240
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_tokens (id, company_id, user_id, email, otp, token, expires_at, used_at, attempts, ip_address, created_at, updated_at) FROM stdin;
934b9127-4767-4532-be4a-21c314b21b73	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	335166	a45f0c5f4cfe84caafbb17762ba87b2094b091577894b8c40d9a4b78fe4aa7e7	2025-12-24 11:43:11.613	2025-12-24 11:35:03.488	0	::1	2025-12-24 11:33:11.61501	2025-12-24 11:35:03.489227
6273b712-ed4a-4639-aed7-06bdeaf2905b	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	299807	d675224c862ea8cb46d8fad4d36a8c0e99eae5db8f43f66846c65af20f448773	2025-12-24 11:45:03.491	2025-12-24 11:36:36.588	0	::1	2025-12-24 11:35:03.49276	2025-12-24 11:36:36.58944
8f8bbb7c-97a6-41c1-9443-e923259c718e	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	799239	8a6f469347020d86a690f63d105322b4cae084de875a58b869faca096523a440	2025-12-24 11:46:36.591	2025-12-24 11:38:26.136	0	::1	2025-12-24 11:36:36.592101	2025-12-24 11:38:26.14324
d8fe3893-bb33-4387-9baa-522529e296da	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	545784	d1d893edaadde8d6a6a9272e8b285beece97ad85ea5c78d90010413bb2684c18	2025-12-24 11:48:26.173	2025-12-24 11:44:30.392	0	::1	2025-12-24 11:38:26.173699	2025-12-24 11:44:30.393386
169aa79c-5b9a-4f88-8570-2c79e6ade5d2	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	419682	2922c8ad00e4558e45bc722bd921b22c3e97851c3e39a1cd35a79038ff95ffcb	2025-12-24 11:54:30.396	2025-12-24 11:47:16.584	0	::1	2025-12-24 11:44:30.39783	2025-12-24 11:47:16.585637
3e6903ab-7d2b-40f9-8ac5-8a16b2e5af1e	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	636370	6fbebeea36e31fb3da203898c856e7b3624fc393fba5b0d13b60c357cd2b56d9	2025-12-24 11:57:16.588	2025-12-24 11:49:57.613	0	::1	2025-12-24 11:47:16.59004	2025-12-24 11:49:57.613771
a5369041-7e1c-49fb-a12c-cb66f94af8f3	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	387270	39949c4f52477439b80b4802d04a52a5dd65d92a9f560ce707b878b9d01f867b	2025-12-24 11:59:57.616	2025-12-24 11:53:26.776	0	::1	2025-12-24 11:49:57.617101	2025-12-24 11:53:26.776464
5e8df032-372b-48be-9262-f51bfd1feb31	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	646804	65ea4a282236dae26a03e073ac1d179db9def9aa4c950a6a788fadcf3577de0b	2025-12-24 12:03:26.778	2025-12-24 11:58:53.803	0	::1	2025-12-24 11:53:26.778425	2025-12-24 11:58:53.803939
0eca5d05-4d3f-401d-a4dc-58d2f1a788d4	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	453841	25f899e516c054601406bec0bf7ad1a70b9d6ab5616ba330b0def464b6b5116a	2025-12-24 12:08:53.806	2025-12-25 00:09:41.982	0	::1	2025-12-24 11:58:53.806344	2025-12-25 00:09:41.983412
abad89df-933d-474a-8c00-c7300de0078e	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	352747	312a4bb31839ebc275b287d29fc835ee0419d3753b052cce1dfdf550bbf69218	2025-12-25 00:19:41.988	2025-12-25 00:10:00.707	0	::1	2025-12-25 00:09:41.990334	2025-12-25 00:10:00.708368
db3ba5fa-39e0-461b-91ba-aeb0c9bec991	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com		8752443df89cf1932faa98c173d158e24e75260a452505545045e43d4394877b	2025-12-25 01:10:00.707	2025-12-25 00:10:14.327	0	\N	2025-12-25 00:10:00.716498	2025-12-25 00:10:14.328018
e0959312-cb04-4645-a92b-e0f77921bf8c	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	vivekebiit@gmail.com	682191	414908617d72a741881996cf37543eb9085ab11baa6b76a8252f1b129e23e619	2025-12-30 17:25:50.686	\N	0	::1	2025-12-30 17:15:50.688198	2025-12-30 17:15:50.688198
\.


--
-- TOC entry 4382 (class 0 OID 65540)
-- Dependencies: 220
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permissions (id, created_at, updated_at, resource, action, description, category, display_order) FROM stdin;
\.


--
-- TOC entry 4403 (class 0 OID 66498)
-- Dependencies: 241
-- Data for Name: priority; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.priority (id, company_id, code, name, description, color_code, icon_name, display_order, default_sla_hours, escalation_hours, is_active, is_system, created_at, updated_at) FROM stdin;
827a5edf-c8eb-43f8-9229-c09cdb4d72f7	eb75a65b-055f-4408-a58c-71d233443c17	LOW	Low	Low priority - can be handled during regular business hours	#4CAF50	arrow_downward	1	72	96	t	t	2025-12-30 10:21:40.256908+05:30	2025-12-30 10:21:40.256908+05:30
b0c08c37-cf14-4d54-8ad1-ddc85a08334f	eb75a65b-055f-4408-a58c-71d233443c17	MEDIUM	Medium	Medium priority - should be addressed within business hours	#2196F3	remove	2	48	72	t	t	2025-12-30 10:21:40.256908+05:30	2025-12-30 10:21:40.256908+05:30
be2dc159-af2b-4e62-ac62-4cd4d41e5328	eb75a65b-055f-4408-a58c-71d233443c17	HIGH	High	High priority - requires prompt attention	#FF9800	arrow_upward	3	24	48	t	t	2025-12-30 10:21:40.256908+05:30	2025-12-30 10:21:40.256908+05:30
95da5640-c887-40ad-9521-d6e08c3ac03d	eb75a65b-055f-4408-a58c-71d233443c17	URGENT	Urgent	Urgent priority - requires immediate attention	#F44336	priority_high	4	4	8	t	t	2025-12-30 10:21:40.256908+05:30	2025-12-30 10:21:40.256908+05:30
\.


--
-- TOC entry 4381 (class 0 OID 65528)
-- Dependencies: 219
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refresh_tokens (id, company_id, created_at, updated_at, user_id, token, expires_at, "ipAddress", "userAgent", revoked_at) FROM stdin;
037b4258-4b8e-4486-88b1-bc432d448fd2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:23:36.215523	2025-12-23 15:34:23.511605	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODM2MTYsImV4cCI6MTc2OTA3NTYxNn0.eC9i4WCH97bepkBzGHNTV2fjxZJTmNG7hkVIQzWVEcE	2026-01-22 15:23:36.213	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 15:34:23.508
51667192-635f-4d33-8c54-bc45aa08e972	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:34:26.538361	2025-12-23 15:36:04.092042	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODQyNjYsImV4cCI6MTc2OTA3NjI2Nn0.VtpKuliFxM8LuxljQdBRHzFIH1dCpKUdEGY7-_j3Zqs	2026-01-22 15:34:26.533	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 15:36:04.091
4cff3995-c8c3-45a6-baf5-9b10d8faec0c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:36:12.78874	2025-12-23 15:36:59.517483	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODQzNzIsImV4cCI6MTc2OTA3NjM3Mn0.VbNMTZ9SKJTXYBLS6leGNLQxVkjWaUNaXHmSG7kCVNU	2026-01-22 15:36:12.788	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 15:36:59.516
3322c73b-bad0-40d0-81b6-75acc17cdd65	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:38:33.217698	2025-12-23 15:47:31.933636	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODQ1MTMsImV4cCI6MTc2OTA3NjUxM30.-bOAkIC0UcADds_ZmlwLGIYT33nulyTw_qbK3hJXpp4	2026-01-22 15:38:33.217	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 15:47:31.933
51894a9f-8bbe-4651-9d25-4696f96df393	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:47:39.924067	2025-12-23 15:57:16.844492	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODUwNTksImV4cCI6MTc2OTA3NzA1OX0.moUczbNGIv6TXqj_wMXdag4Pf-V14ZTaxeGy8vz_qys	2026-01-22 15:47:39.923	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 15:57:16.843
9ef7a8c2-92d5-4f21-bd4e-f36275bd4045	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:58:19.727783	2025-12-23 15:59:07.263615	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODU2OTksImV4cCI6MTc2OTA3NzY5OX0.2_LcMQ_BNP_E1UCEPg9fkVFH7KnxpQ7j_xo7VLp05Hw	2026-01-22 15:58:19.727	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 15:59:07.263
782f316a-601b-46a8-b48a-3158227b18d6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 16:15:01.905725	2025-12-23 16:16:51.462832	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODY3MDEsImV4cCI6MTc2OTA3ODcwMX0.R7ZyId7Oy2yHMNgaDCdMGLS7cedc_oPaHDP_U8KFXjE	2026-01-22 16:15:01.903	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-23 16:16:51.46
69a513b6-a19b-4b28-9fce-d34cbc7f255d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:59:09.612013	2025-12-23 21:16:48.712595	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODU3NDksImV4cCI6MTc2OTA3Nzc0OX0.M2eGzuev_db3BGCjIvzGCs50LMNXJ1Ub8KGPqBXcZ1k	2026-01-22 15:59:09.611	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 21:16:48.711
caebe2eb-9007-4952-a09b-e81bbb21c1d6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 16:40:56.225319	2025-12-23 16:58:09.331225	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODgyNTYsImV4cCI6MTc2OTA4MDI1Nn0.flsyOpVLR6cKzxMeJO01ijo2cvVkiN-_N-uvaL2sjbM	2026-01-22 16:40:56.223	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-23 16:58:09.33
43448667-3368-41a0-8eac-99882fa4049c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 16:27:20.824455	2025-12-23 17:03:12.967287	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODc0NDAsImV4cCI6MTc2OTA3OTQ0MH0.YhR-wWh_FVBPjPweNUuqbl1gBVezsaoxSPlh1JOH0Is	2026-01-22 16:27:20.824	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-23 17:03:12.965
cb1aecd4-7e2c-4fce-ac72-e723b299200f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 16:58:09.320528	2025-12-23 17:03:12.967287	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODkyODksImV4cCI6MTc2OTA4MTI4OX0.KoZaC5zCHjyTt3sV050ddAZFTToS58wNYlNCaWelEBo	2026-01-22 16:58:09.319	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-23 17:03:12.965
dc1640e1-bba8-464e-b072-1d66a26bbd1b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 18:25:13.295019	2025-12-23 18:43:36.746326	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0OTQ1MTMsImV4cCI6MTc2OTA4NjUxM30.3ZKr58dPk6CU12e_b2xo7U-BRsRHsYfHxEWWmZvUS3E	2026-01-22 18:25:13.293	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-23 18:43:36.745
1b8fd6af-5f3e-4310-800e-bdec015e4a35	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 18:43:36.738705	2025-12-23 21:12:24.388415	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0OTU2MTYsImV4cCI6MTc2OTA4NzYxNn0.H4tb9wYdJDUtvhZBbvhr3EPKk6uTP4-1Or1O5Rhw6V0	2026-01-22 18:43:36.735	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 21:12:24.387
8b5423e5-d2d7-4cba-b6d3-ff7c361b03f6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 16:17:06.030653	2025-12-23 21:16:48.712595	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODY4MjYsImV4cCI6MTc2OTA3ODgyNn0.IKGRKxORATD6B_zRBnu5wzgJroIo43PVucd_u3dkPgQ	2026-01-22 16:17:06.029	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 21:16:48.711
e7c4df89-dc0a-46b9-a781-6b8768c6fa04	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 17:03:19.633624	2025-12-23 21:16:48.712595	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0ODk1OTksImV4cCI6MTc2OTA4MTU5OX0.aUjfc13ZBUqSXJRQWDjV9dR7R_u3fE0bVbs_dRyfTR4	2026-01-22 17:03:19.633	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-23 21:16:48.711
f86880a2-b7eb-4268-a6e4-15f8feaaa13f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 17:40:47.306354	2025-12-23 21:16:48.712595	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0OTE4NDcsImV4cCI6MTc2OTA4Mzg0N30.8x3Sx9fZtBTDjBEo9h2-VPzhiSIqXXho1i2flCrQ5CI	2026-01-22 17:40:47.304	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-23 21:16:48.711
8b8205b5-166a-42b9-a590-176fbd50e151	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 17:16:34.144116	2025-12-24 13:13:23.674804	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0OTAzOTQsImV4cCI6MTc2OTA4MjM5NH0.qETg4PyWaO0JQMURPGM3XOYhv5wF5WhTZ7MyaaWasXI	2026-01-22 17:16:34.143	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 13:13:23.671
1401bda0-51ed-4798-b82f-9cb0a51988ac	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 18:08:06.507176	2025-12-23 21:16:48.712595	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0OTM0ODYsImV4cCI6MTc2OTA4NTQ4Nn0.L_HpuknDHd8mDpDFVX6tblbiIy8Zv2OHnvj0vjgXRmk	2026-01-22 18:08:06.506	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 21:16:48.711
06f7184c-f12d-4255-988e-2c6ae1e67d33	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 18:09:57.939301	2025-12-23 21:16:48.712595	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY0OTM1OTcsImV4cCI6MTc2OTA4NTU5N30.M8yI2vbos_pu9-t6PafI4mmc4TSuXvxExF8MH8Fy0KU	2026-01-22 18:09:57.938	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-23 21:16:48.711
db749ec7-38ab-44df-955c-6b4037ca62fe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 21:12:24.319298	2025-12-23 21:16:48.712595	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1MDQ1NDQsImV4cCI6MTc2OTA5NjU0NH0.UIUN-08Y-hDXLEjVack-wenbgziCU8JohGWg9Uxn298	2026-01-22 21:12:24.317	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 21:16:48.711
242841f2-47d1-4a25-ba03-934cf4ed9cf9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 21:16:50.319408	2025-12-23 21:24:59.972994	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1MDQ4MTAsImV4cCI6MTc2OTA5NjgxMH0.0EPIbNHuaFiuhHAXwhrU3gnSODQYQ-ywDD_zsxL-c2Y	2026-01-22 21:16:50.319	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 21:24:59.971
bbf81d88-db76-4060-a0d9-544b7f2cfdaa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 21:25:01.090169	2025-12-23 22:03:09.322984	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1MDUzMDEsImV4cCI6MTc2OTA5NzMwMX0.JNSyR2_Pt1zfiTcBL2wpXdGQTBb6aNjYWDLZptyMcPo	2026-01-22 21:25:01.089	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 22:03:09.322
11c09d5d-7838-48ea-983b-9ceebe116089	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 21:46:43.132307	2025-12-23 22:03:09.322984	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1MDY2MDMsImV4cCI6MTc2OTA5ODYwM30.-KPunN7UfWafNtc5zvR2r96V_CmwxIdaxesB1ZEJriE	2026-01-22 21:46:43.13	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 22:03:09.322
063e4427-f728-4c3a-8fdc-0e977d456acc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 21:58:42.862459	2025-12-23 22:03:09.322984	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1MDczMjIsImV4cCI6MTc2OTA5OTMyMn0.TM193v3YkKmUZX9SfURmqAHggro4laolm0VBHUqreQE	2026-01-22 21:58:42.861	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 22:03:09.322
226fdcf1-5bf6-4693-a88e-f4aa3d62f277	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 22:03:33.357287	2025-12-23 22:03:49.460476	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1MDc2MTMsImV4cCI6MTc2OTA5OTYxM30.M8g147HX851CJdksjZLAe6LC7GaZ4PAyh57F64TOdjw	2026-01-22 22:03:33.357	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-23 22:03:49.459
31e52553-ca9c-4347-8ff4-9c77dab6818a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 22:03:52.849883	2025-12-24 10:53:24.739575	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1MDc2MzIsImV4cCI6MTc2OTA5OTYzMn0.WSvl0UKgI8rPVYrauUhEBudExHCvysB_Di37Mfgl0Jk	2026-01-22 22:03:52.849	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-24 10:53:24.739
714fa56b-7c3c-469a-83d6-738ae5ebbdda	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 10:45:29.920729	2025-12-24 13:13:23.674804	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NTMzMjksImV4cCI6MTc2OTE0NTMyOX0.DvMdrrtDFQEIirE-70QGjSTgDidyelcu-1Qmrm8UDMA	2026-01-23 10:45:29.917	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 13:13:23.671
6f819655-7317-4019-8948-955d932e6d4d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 10:50:06.977256	2025-12-24 10:53:24.739575	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NTM2MDYsImV4cCI6MTc2OTE0NTYwNn0.M-IWadn82nhCPockikYJ3QGYTpRiKMr_Y6B94MtKfDI	2026-01-23 10:50:06.976	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 10:53:24.739
835f7aab-08ab-4071-a20d-5e35ef921228	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 11:22:19.508508	2025-12-24 11:22:24.218693	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NTU1MzksImV4cCI6MTc2OTE0NzUzOX0.4R1bywMzOz6meG85Y-ZUbLMxdnoYYS5krK65ceTtzsE	2026-01-23 11:22:19.507	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 11:22:24.217
c59c1d5a-fc28-4d5a-a894-29944886e1bb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:03:30.757605	2025-12-24 12:19:04.345379	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NTgwMTAsImV4cCI6MTc2OTE1MDAxMH0.yXwazHmVFxEawgl_eqUpvhgX2A_IHBimUQI4HdiCWGM	2026-01-23 12:03:30.756	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-24 12:19:04.344
7ea765a2-7266-4dcc-b0eb-94f0badf7de4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:19:04.336614	2025-12-24 12:29:17.8861	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NTg5NDQsImV4cCI6MTc2OTE1MDk0NH0.nOBcKU1v3C_uiakPxjQp3L73czk4aVNMvTJLUEs3UwY	2026-01-23 12:19:04.336	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-24 12:29:17.885
1ad90e39-cb04-4857-98d1-26c78497db4b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:29:29.629499	2025-12-24 12:45:23.805207	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NTk1NjksImV4cCI6MTc2OTE1MTU2OX0.VoJb8ofmJIpqKv--PQRjy_Dut-jVmbr4kgT2zkXeCmo	2026-01-23 12:29:29.629	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 12:45:23.804
5c6ad213-3ade-49d0-9b73-e77e1906ec2d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:45:23.725225	2025-12-24 13:03:57.395335	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjA1MjMsImV4cCI6MTc2OTE1MjUyM30.fF5w3jogVe1o3IqYhChD1EPE1uLjVa-4zuSWMnOJUfg	2026-01-23 12:45:23.724	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 13:03:57.389
dc26bd03-f72b-4ce4-87b0-f3b9e02cac25	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:03:57.359395	2025-12-24 13:13:23.674804	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjE2MzcsImV4cCI6MTc2OTE1MzYzN30.LgFMrsgoU-paxQxDjJ-bg6S4oKtuIi2KgdTkBfWMenE	2026-01-23 13:03:57.341	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 13:13:23.671
2dc44b43-0792-48a9-b090-d823ceaf4a5b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:04:28.014467	2025-12-24 13:13:23.674804	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjE2NjcsImV4cCI6MTc2OTE1MzY2N30.xbGVLlwkLcP9LBKrr4O0ZLgEmHQ6dh7LpexPaHaidCE	2026-01-23 13:04:27.98	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 13:13:23.671
dcf309f4-2fdd-4074-a5f4-4aaebc4014d0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:27:28.037465	2025-12-24 13:43:43.843434	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjMwNDgsImV4cCI6MTc2OTE1NTA0OH0.CLHtK5BVG4KAu7XEOkOQXg2YLUSnYA-rPda8mCJwyOY	2026-01-23 13:27:28.037	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 13:43:43.843
096ed6c4-728e-46f9-b4af-103d431f24a7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:43:43.813977	2025-12-24 13:59:14.106659	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjQwMjMsImV4cCI6MTc2OTE1NjAyM30.qD5DVjKdJp-0HG5EQmUUdKGdmJq36lNSZEGQnYd_D7c	2026-01-23 13:43:43.813	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 13:59:14.106
02f285fa-4696-4ed3-bb11-9063febd0517	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:59:14.092963	2025-12-24 14:14:28.859295	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjQ5NTQsImV4cCI6MTc2OTE1Njk1NH0.ZklfAbveeSD0LhUHi6ZhILkiHWrM8GFB2Q5yj6zGMdE	2026-01-23 13:59:14.092	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 14:14:28.855
e1d6bd4e-23df-496c-8db5-f65c00565676	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 14:37:06.212085	2025-12-24 14:52:18.577673	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjcyMjYsImV4cCI6MTc2OTE1OTIyNn0.8ZFjHvt8qwRVyACvNpr4737c7IgN8qfkPChVGDyfh7o	2026-01-23 14:37:06.211	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 14:52:18.577
a722af49-cb6b-4991-aa13-4595c68320a4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 14:52:18.570712	2025-12-24 15:07:37.756626	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjgxMzgsImV4cCI6MTc2OTE2MDEzOH0.cWdKzICIlh8oFarWtvydaXtz1NARikuO9F37mT80H0U	2026-01-23 14:52:18.57	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 15:07:37.756
4de4f56c-f3f5-4cd1-928d-ac4755517347	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 15:07:37.74286	2025-12-24 15:22:37.616228	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjkwNTcsImV4cCI6MTc2OTE2MTA1N30.yyePfe-5HbKRnOP2ifX0EhTzR8yo5dvmhLRe9jq-M6w	2026-01-23 15:07:37.742	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 15:22:37.615
d0302c4d-3f00-4e36-bbf3-3205e3e94204	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 15:37:15.961345	2025-12-24 15:52:21.239237	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzA4MzUsImV4cCI6MTc2OTE2MjgzNX0.pJREyytlGXFfzj2j_lbWC3KyUnuXcQBFm9rdZkBMON0	2026-01-23 15:37:15.96	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 15:52:21.238
0e42db48-2f76-4df4-8c11-93eca470536a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 15:52:21.217563	2025-12-24 16:08:26.945617	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzE3NDEsImV4cCI6MTc2OTE2Mzc0MX0.jXGpkDNu6BzaaP8NXvuGNZHj4wqvS7Hf5fhQt39bzCs	2026-01-23 15:52:21.216	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 16:08:26.944
2a5b2fbe-0987-43d2-99b7-eb867f742220	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:13:33.267883	2025-12-24 17:02:00.259061	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjIyMTMsImV4cCI6MTc2OTE1NDIxM30.I6YKAkMYi97dp-b3tqO5B52ZHY_r40Uo26TGYVUtV3E	2026-01-23 13:13:33.267	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 17:02:00.257
2ed3e1d8-f63d-4dd8-89e0-475940f436fd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 16:18:08.405912	2025-12-24 16:33:45.790149	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzMyODgsImV4cCI6MTc2OTE2NTI4OH0._UbZBegY5cYxmyKCqYhcpnSls42YzTAX2ncboQuLY3w	2026-01-23 16:18:08.405	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 16:33:45.789
3677748d-cc65-409d-9ebc-8a244d156816	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 16:33:45.772341	2025-12-24 16:49:47.740235	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzQyMjUsImV4cCI6MTc2OTE2NjIyNX0.OzifFrU6bHE36Ujb4l3YBcDD-rbrGhif3UWBCrRDEfc	2026-01-23 16:33:45.771	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 16:49:47.739
4893d4f4-b7fb-4ae2-b763-559e9b25513e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 14:14:28.833319	2025-12-24 17:02:00.259061	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjU4NjgsImV4cCI6MTc2OTE1Nzg2OH0.JQGPdBQd-H6RJzwxUIylWIaYeAuKW4CjkVGGCkJOUzc	2026-01-23 14:14:28.832	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 17:02:00.257
34c0d11c-e480-421f-99b6-e9c48ccc2b4d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 14:15:38.858246	2025-12-24 17:02:00.259061	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NjU5MzgsImV4cCI6MTc2OTE1NzkzOH0.Ms8-FojXNoWFJJUua8jmPI6ZDo3N2N35NBZ6KDDaAv4	2026-01-23 14:15:38.857	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 17:02:00.257
6dfedcdc-f905-496b-9514-aaaae740537f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 15:22:37.597912	2025-12-24 17:02:00.259061	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1Njk5NTcsImV4cCI6MTc2OTE2MTk1N30.8nULXdWqLgnwJmuqfUxkIF1TGNsGHj5NR6sFVdhxuNk	2026-01-23 15:22:37.596	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 17:02:00.257
d1f8bcaa-f720-48ee-a9e7-4c5d7c7faed0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 16:08:26.931569	2025-12-24 17:02:00.259061	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzI3MDYsImV4cCI6MTc2OTE2NDcwNn0.zNOsdC-dJISforSHdZpK0QUM0csNFVksaIH4qS8LJ-o	2026-01-23 16:08:26.93	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 17:02:00.257
070c1462-9a45-4494-b85b-c4d7cd49ced4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 16:49:47.733264	2025-12-24 17:02:00.259061	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzUxODcsImV4cCI6MTc2OTE2NzE4N30._QFmR74olYhgAMTZiKiZ2ohDhEMwCco5YpdHAy-l2eE	2026-01-23 16:49:47.732	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 17:02:00.257
219478e8-1314-4b5b-a975-5f9077cbc460	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 16:59:44.372608	2025-12-24 17:02:00.259061	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzU3ODQsImV4cCI6MTc2OTE2Nzc4NH0.HJKEqbWOKEmRUUrEl6Dp9LF0HEogJSuOnesuFX6q0z0	2026-01-23 16:59:44.372	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 17:02:00.257
c1ae1e0b-c91f-44e8-bd7b-16c3af1ab55b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 17:04:09.451441	2025-12-24 18:19:00.595606	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzYwNDksImV4cCI6MTc2OTE2ODA0OX0.X-VfcY0NvOp0Wt1BiAWaScx-BfQuvYPYWw13ax5KBBc	2026-01-23 17:04:09.451	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 18:19:00.595
56033fe1-d940-4098-911b-1bc6b5345d09	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 17:10:09.727726	2025-12-24 18:19:00.595606	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzY0MDksImV4cCI6MTc2OTE2ODQwOX0.8VkrN88fWk3Wq8oeMIj-gZ9yFee1R4sPq751WCgUu3U	2026-01-23 17:10:09.727	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 18:19:00.595
0ea26874-1381-4184-b084-03ff43bf333d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 17:29:39.040418	2025-12-24 18:19:00.595606	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1Nzc1NzksImV4cCI6MTc2OTE2OTU3OX0.FkE1nl6DpSNbs3V-ZRdPxB5FfE-g1t44SmBzkXDKFW8	2026-01-23 17:29:39.039	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 18:19:00.595
e485fb41-e6e2-4675-ad2f-710f38191c44	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 17:44:49.731361	2025-12-24 18:19:00.595606	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1Nzg0ODksImV4cCI6MTc2OTE3MDQ4OX0.tUtgkjdcwbs5b_JMs0K48XsxOzvA05MmgeYkOsEzGvI	2026-01-23 17:44:49.73	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 18:19:00.595
9763a44c-f006-4597-ad11-a5ea23cf5c8f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 17:56:15.515446	2025-12-24 18:11:38.503893	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1NzkxNzUsImV4cCI6MTc2OTE3MTE3NX0.4m2rVYFfUnR8zk-phTQDuUsczQQyTiM73e4Px2R3nxs	2026-01-23 17:56:15.513	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 18:11:38.503
410f437a-eaac-42d1-b13a-cfe339c40f70	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 18:11:38.497319	2025-12-24 18:19:00.595606	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1ODAwOTgsImV4cCI6MTc2OTE3MjA5OH0.VrA6MBlk-T-sh-A1wQYfe36Bs6lImWLvLKDwWHkcEzI	2026-01-23 18:11:38.497	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 18:19:00.595
51beafd1-ed62-45dc-8387-ac74ec6373fa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 18:18:02.936363	2025-12-24 18:19:00.595606	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1ODA0ODIsImV4cCI6MTc2OTE3MjQ4Mn0.qbH8TOYG4xfJZuM2Lpy2MY2wMfpTd2TlSdHuSOAxBhg	2026-01-23 18:18:02.936	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 18:19:00.595
0adfe88f-5cac-45d8-a7e4-6bdbdaab549e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:51:03.312785	2025-12-24 22:52:25.748642	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTY4NjMsImV4cCI6MTc2OTE4ODg2M30.2u6nCxgMhsm6zQb1c3GUinUwQ04xR4VbiQR1z2_RTmM	2026-01-23 22:51:03.312	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 22:52:25.748
2767ae84-8bc0-447a-b586-853ec6d00e98	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:52:35.110817	2025-12-24 22:53:34.581943	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTY5NTUsImV4cCI6MTc2OTE4ODk1NX0.AiRxtPkVmPhUhsyDIh8Gp1OAxIDV4JfqJtK7xr7XC6Y	2026-01-23 22:52:35.11	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 22:53:34.581
06cc5d3b-f6bb-44be-8087-c708c8ee1063	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:53:42.43021	2025-12-24 22:53:52.312413	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTcwMjIsImV4cCI6MTc2OTE4OTAyMn0.0zBpv9j1tff6CLeQWQLOYADkT-YUbfXSBe_9QI0O5Zc	2026-01-23 22:53:42.43	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 22:53:52.312
8fef7e1a-ea3e-4b06-82da-ddd1cc50a757	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:54:09.519367	2025-12-24 23:06:59.392155	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTcwNDksImV4cCI6MTc2OTE4OTA0OX0.sb8xpZLvZ-rd7FRBQNZM1NEnN8tUp_r8_WF10kfy09U	2026-01-23 22:54:09.519	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 23:06:59.391
c6f14d4b-c68b-43ed-9f71-3c1a6b7d6fd7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 23:07:12.169859	2025-12-24 23:17:36.709816	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTc4MzIsImV4cCI6MTc2OTE4OTgzMn0.SGuyuMGArpqx49hclr_PiEjrBxGdt76c6sRCQWIGPSs	2026-01-23 23:07:12.169	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-24 23:17:36.709
7cd3cdc8-1dcc-41f2-a4ad-0d96638dc26d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 23:18:02.36457	2025-12-24 23:33:22.211177	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTg0ODIsImV4cCI6MTc2OTE5MDQ4Mn0.7zWQzQXeslKW02AxiUcVu3WfFtoSsLEkeFDW-Zlsir4	2026-01-23 23:18:02.364	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 23:33:22.21
057e7ef3-67e5-45f1-9f90-f745b220ca3d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:55:13.04519	2025-12-24 23:37:41.292728	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTcxMTMsImV4cCI6MTc2OTE4OTExM30.H_5c8zV4KCD06cCMKO9_gN3J4c8hKZla1vkndlPPTJs	2026-01-23 22:55:13.044	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-24 23:37:41.292
263ab374-4718-47fc-b452-c038aa8e5aaa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 23:33:22.190883	2025-12-24 23:51:09.646057	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTk0MDIsImV4cCI6MTc2OTE5MTQwMn0.Uyr6qHhhwtRMwCOeAbHw4jpmDcL7Ary5HLu0aTX37Ww	2026-01-23 23:33:22.189	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-24 23:51:09.645
e3df2611-2704-4467-819c-439444c948a0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 23:37:41.281534	2025-12-25 00:04:27.767686	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY1OTk2NjEsImV4cCI6MTc2OTE5MTY2MX0.etQMgCEX6XtPbu3gXWCvpC0GJ842G5HJDTe2Hy6ZBCg	2026-01-23 23:37:41.281	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 00:04:27.766
113a9571-4cfe-4f90-889c-3b294d5f8d44	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 23:51:09.634523	2025-12-25 00:04:27.767686	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MDA0NjksImV4cCI6MTc2OTE5MjQ2OX0.Dpgozahf4ylV6g6uzUSV1nLAEnC4jM78I8pYP-0bPLA	2026-01-23 23:51:09.633	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-25 00:04:27.766
eea8ba3d-4e72-42ab-b673-a0ba53878f1f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:10:29.084528	2025-12-25 00:10:33.884119	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MDE2MjksImV4cCI6MTc2OTE5MzYyOX0.Z52FBTNTuOlrkZgWkqstM0ogsXdIpOhC_jCBBbouCD0	2026-01-24 00:10:29.084	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 00:10:33.883
5d33dd4e-ffdf-4aa0-9eca-69c071418765	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 07:15:48.359616	2025-12-25 07:40:03.2296	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MjcxNDgsImV4cCI6MTc2OTIxOTE0OH0.zYbcYjLuzmrKZH5od_OuFfLCtoTLuiqd1iFkfz9Xpes	2026-01-24 07:15:48.359	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 07:40:03.228
ea1ce129-95e5-431a-a695-80854c242223	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 07:40:03.202892	2025-12-25 08:24:13.452014	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2Mjg2MDMsImV4cCI6MTc2OTIyMDYwM30.PRXVyWrPC2APFEDSsiAf3Dn7-nCfyEKmdN2zzPVakJI	2026-01-24 07:40:03.2	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 08:24:13.45
341f4532-af49-4e97-a8a9-bef0916ec8c0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 08:24:13.298102	2025-12-25 08:39:16.516958	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MzEyNTMsImV4cCI6MTc2OTIyMzI1M30.oToYs51LzPApgaWXKheamWr1v0ZSu-kB-q-R_acQK7Y	2026-01-24 08:24:13.296	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-25 08:39:16.515
be2af799-e13d-4139-a1ff-e94084768c9d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 08:39:16.509286	2025-12-25 09:05:27.085161	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MzIxNTYsImV4cCI6MTc2OTIyNDE1Nn0.V9L_F8_MyCKtugkMVrIlXQ3IDhvzNfSvd1k-nwzZ0W4	2026-01-24 08:39:16.508	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-25 09:05:27.084
6e3645cd-616c-4dd3-b3b9-8e380e7a010b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 09:05:27.077684	2025-12-25 09:20:40.427248	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MzM3MjcsImV4cCI6MTc2OTIyNTcyN30.ibK0hL17hfbipOthULZnlCy81ro7ISZgYfWnZArpc2o	2026-01-24 09:05:27.077	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 09:20:40.426
50cb6082-5b57-4456-863d-609c5cdb7bbb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 09:20:40.419473	2025-12-25 09:37:09.804847	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MzQ2NDAsImV4cCI6MTc2OTIyNjY0MH0._nbcruWONuN9G94v2PM-RtjvNfnoOP5qTc65pdXfW38	2026-01-24 09:20:40.418	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 09:37:09.804
a4a7e8f1-2039-4a9d-ba16-449eec8eef95	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 06:45:10.922413	2025-12-26 07:21:14.021247	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MTE3MTAsImV4cCI6MTc2OTMwMzcxMH0.XmVi7OUBjI5Qpb1maC2tw2ih97diKPLXridQvURIh8E	2026-01-25 06:45:10.921	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 07:21:14.02
8f3c592a-e4cb-477d-81a9-077b8c4b847d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 07:21:06.890075	2025-12-26 07:21:14.021247	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MTM4NjYsImV4cCI6MTc2OTMwNTg2Nn0.WjMtMjXKXYLE6tWAIJR7GHBU_5Kgd2wJypUes8y6cjU	2026-01-25 07:21:06.889	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:21:14.02
f6760284-45e4-46f8-8ddf-0753fc7b5ffc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 07:21:24.403166	2025-12-26 07:21:36.626162	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MTM4ODQsImV4cCI6MTc2OTMwNTg4NH0.hB2Np-uM4eMehT4Fe-CvzOvdzMPtcJ_ohjFs5Vu78U4	2026-01-25 07:21:24.402	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:21:36.625
42d7c1cc-44ac-4e34-8a61-c9f3d26f2721	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 07:21:54.847867	2025-12-26 07:21:59.482594	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MTM5MTQsImV4cCI6MTc2OTMwNTkxNH0.wkrmvx3m-6vStYpAJ73V7GPGU3ImbI7oElbflt0Kk-k	2026-01-25 07:21:54.847	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:21:59.482
5b101149-f879-42a0-8335-81c8ab6cdba3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:10:47.257095	2025-12-26 10:39:12.36603	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MDE2NDcsImV4cCI6MTc2OTE5MzY0N30.n3ND1ocmqOKiyhd4bYQarYZF5ixrvEsaSyB4LR5bP48	2026-01-24 00:10:47.256	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 10:39:12.365
96255616-bc3c-4f48-9e4a-c93aa1e6e0a3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 07:25:38.061031	2025-12-26 07:25:42.732779	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MTQxMzgsImV4cCI6MTc2OTMwNjEzOH0.SYkcycxjpzF3O9W0kC_Z-JdcUnSQYflO2IfzdCQdAxk	2026-01-25 07:25:38.06	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:25:42.732
90381da4-f18e-4024-86db-aaf19cea2d6a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 07:30:20.310194	2025-12-26 07:30:26.153227	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MTQ0MjAsImV4cCI6MTc2OTMwNjQyMH0.4-wp_S8_CUfOD2h6ZJMLD0f2kvqAXsoKE0cku4GgFYA	2026-01-25 07:30:20.309	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:30:26.153
f7d22c1d-b7de-4ad7-96d4-4222b7f38e8d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 08:57:45.356673	2025-12-26 08:57:50.817333	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MTk2NjUsImV4cCI6MTc2OTMxMTY2NX0.NWPaWKpL0J0e9RuILrvRVA_g5-Jobugils2UpeJ7dHI	2026-01-25 08:57:45.356	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 08:57:50.816
3a2e86b6-80c4-4571-aaaa-62719b4d9455	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 09:02:11.234917	2025-12-26 09:02:56.181281	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MTk5MzEsImV4cCI6MTc2OTMxMTkzMX0.4FkOxhIgg9fl97MgHFNj3JTNgvkGLMWS8LygMQfT8lM	2026-01-25 09:02:11.234	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 09:02:56.18
eb1827a4-0c7b-4ba5-94d7-394402fb0545	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 09:13:38.482443	2025-12-26 09:13:43.372178	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjA2MTgsImV4cCI6MTc2OTMxMjYxOH0.Y8w64Ht9phCElRm3Cf8cu6-mtC8-9I5R5N9yJeiaY0w	2026-01-25 09:13:38.482	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 09:13:43.372
d0faf713-921f-4f20-b35e-4b55609ddf10	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 09:17:21.824261	2025-12-26 09:17:26.967329	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjA4NDEsImV4cCI6MTc2OTMxMjg0MX0.ysIgjIB6GrYmtLpcfL4KDE9dkGvL8EAVn6DAec9ceo4	2026-01-25 09:17:21.823	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 09:17:26.967
86a90a3e-e8ba-4642-a4a0-006d4faf6246	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 09:24:53.067659	2025-12-26 09:39:50.971865	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjEyOTMsImV4cCI6MTc2OTMxMzI5M30.whlrx4NQ9avcr3y8RN6ofGx7C1fLPEWmdSH9OG_LYmk	2026-01-25 09:24:53.067	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 09:39:50.971
337128c8-9a7a-42ae-836c-de1e7e74642b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 09:28:41.115449	2025-12-26 09:39:50.971865	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjE1MjEsImV4cCI6MTc2OTMxMzUyMX0.SSCT5qhunj0bCfgcLy1p8KJztkA_vr6dFIclAmGmtK0	2026-01-25 09:28:41.115	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 09:39:50.971
7a6613f1-d085-4ae9-81b8-d7979335a12d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 09:39:44.122014	2025-12-26 09:39:50.971865	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjIxODQsImV4cCI6MTc2OTMxNDE4NH0.Yu4iftN0uf940yuAdphdNRq-AJh67vWYZpST9fs1Vvg	2026-01-25 09:39:44.121	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 09:39:50.971
a12a856b-4845-4b43-b72b-a774efe7255c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:20:03.599724	2025-12-26 10:37:44.622682	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjQ2MDMsImV4cCI6MTc2OTMxNjYwM30.s_-66E3xtyWSy4LDc3ICvwFOKGhdnfCljgDO5JBI8Mk	2026-01-25 10:20:03.599	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 10:37:44.622
88742452-5a4f-49a9-9523-ce82ec0bfd7a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 07:01:43.63769	2025-12-26 10:39:12.36603	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MjYzMDMsImV4cCI6MTc2OTIxODMwM30.NQgKwZ7FTkJGLScOBijpKfVViAHUU6lyqOGN6LMjjak	2026-01-24 07:01:43.637	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 10:39:12.365
4082106b-8e9a-4c3f-a79c-1b8ff05b6d38	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 09:37:09.796287	2025-12-26 10:39:12.36603	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY2MzU2MjksImV4cCI6MTc2OTIyNzYyOX0.BZCt4y4P5x8Z6kiJmecR03nDL3sWS0Av-LKsvTIEgVw	2026-01-24 09:37:09.795	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 10:39:12.365
d46a6bde-f099-46a7-accc-1260f51018e8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:37:44.615904	2025-12-26 10:39:12.36603	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjU2NjQsImV4cCI6MTc2OTMxNzY2NH0.kOVuzLgNMLVs-EvNMvyb0uh0BDyB2-aF0RPS72DOVh0	2026-01-25 10:37:44.615	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 10:39:12.365
3eaf3ddb-1555-4582-b74c-a5f9acbffcf5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:40:08.900576	2025-12-26 10:49:34.008678	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjU4MDgsImV4cCI6MTc2OTMxNzgwOH0.doa39XrLDb3kpBAXV9VqcRcFw_sH9l6CIJQzdW4TyWo	2026-01-25 10:40:08.9	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 10:49:34.007
6325b73f-8ae9-463a-96a5-8e8b7cf4b8bd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 09:52:33.843129	2025-12-26 13:51:45.904908	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjI5NTMsImV4cCI6MTc2OTMxNDk1M30.szQgEIWA9bZeO-Ks7dDuB4andhVh1FfJS90WorNTNYA	2026-01-25 09:52:33.842	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 13:51:45.902
ae0bbffe-ed02-4840-b540-9714faeef619	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:49:36.264656	2025-12-26 10:50:41.057141	be3cf16a-1466-4065-a1b0-47ff590bc0b4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiZTNjZjE2YS0xNDY2LTQwNjUtYTFiMC00N2ZmNTkwYmMwYjQiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjYzNzYsImV4cCI6MTc2OTMxODM3Nn0.fxJlwTogU7AjwB2NbtE-_pPSGuxInZn9cRyYlDkB5Dw	2026-01-25 10:49:36.264	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 10:50:41.056
eca46024-e0c5-4385-b2c2-c6a405bedd77	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:51:01.108603	2025-12-26 10:52:10.368818	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjY0NjEsImV4cCI6MTc2OTMxODQ2MX0.2HCFKwlbZexTTq-vsfp7xtkBS8EjIDt7q4g7hwQwaUk	2026-01-25 10:51:01.108	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 10:52:10.368
df5447af-2bc0-4488-bb84-8b2cc969b729	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:52:27.680238	2025-12-26 10:53:53.048708	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjY1NDcsImV4cCI6MTc2OTMxODU0N30.J9nZV2hliQEQ8CzNkMUUoC_UTa042rzI_XU-PStLCVA	2026-01-25 10:52:27.679	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 10:53:53.048
1adb3839-72ac-4f15-9a85-d3d8493d96c5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:54:31.677905	2025-12-26 11:16:13.999689	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjY2NzEsImV4cCI6MTc2OTMxODY3MX0.3F7hdzVhR2rUvQQJ1PZBd5yCDXcHQ_drRynolRKpDtY	2026-01-25 10:54:31.677	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 11:16:13.999
fd671fa1-808f-4992-963a-e22fd64e644a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 11:16:13.97411	2025-12-26 11:16:20.198232	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3Mjc5NzMsImV4cCI6MTc2OTMxOTk3M30.7MX_ZpautVT4IOD22bGylWvex4_bQU9PhEm2I2bXlYw	2026-01-25 11:16:13.973	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 11:16:20.198
03470855-55df-4ced-964f-c25213b84159	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 11:21:30.761932	2025-12-26 11:37:14.489564	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjgyOTAsImV4cCI6MTc2OTMyMDI5MH0.AQJEpjzRAsg6s-jhAzNuHAZyTSPtJn8S6SuXw8Ji8mY	2026-01-25 11:21:30.761	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 11:37:14.487
752af94e-a5d5-47f8-94f8-0fec1840bb87	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 11:37:14.474914	2025-12-26 12:01:59.842151	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjkyMzQsImV4cCI6MTc2OTMyMTIzNH0.qfsEv1FReQcDwuJuhfFwSzcC1euv-bLS5RJkiEedz7U	2026-01-25 11:37:14.472	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 12:01:59.841
dcca8a55-a570-4d53-a3dd-dfab0f0860c2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:48:26.896931	2025-12-26 12:02:16.892433	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MjYzMDYsImV4cCI6MTc2OTMxODMwNn0.F4JXHxSG7G2U3LGlhMLzNgYrw1JOhbQN6hy3gcWv240	2026-01-25 10:48:26.896	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 12:02:16.891
4648c8cf-1690-49ec-9c6d-bbcf877f5bf7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 11:16:37.463297	2025-12-26 12:02:16.892433	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3Mjc5OTcsImV4cCI6MTc2OTMxOTk5N30.mcwMSRI3rMfHWdjPV69vIhHSS9tbqOXvcygugpOGH4E	2026-01-25 11:16:37.463	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 12:02:16.891
d43426d0-410a-4175-addd-e1f5c794a6ec	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 12:01:59.830326	2025-12-26 12:02:16.892433	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzA3MTksImV4cCI6MTc2OTMyMjcxOX0.Zr6FZjMj4uCUQ2UpcYz4lxu2APVl6v-vpak312ejT7g	2026-01-25 12:01:59.828	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 12:02:16.891
e18ad858-6a94-42cb-ac7a-52465fb6815d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 12:10:07.009692	2025-12-26 12:12:07.742233	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzEyMDcsImV4cCI6MTc2OTMyMzIwN30.wW8Lf7QJ9-CLNk5bPVLSUePtAr5rOzq9DlkQ4rTGGKc	2026-01-25 12:10:07.001	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 12:12:07.741
ee9ad316-c010-42ae-ac4e-99c5e2f57fc0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 12:14:34.044467	2025-12-26 12:33:48.13484	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzE0NzMsImV4cCI6MTc2OTMyMzQ3M30.WoSGXbf_Sj_TFgAqfWh_d_ijvqWvdbORTPXvB_L3tew	2026-01-25 12:14:33.919	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 12:33:48.13
6a77edda-823e-4158-8233-65b3ba8a6a31	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 12:30:50.510994	2025-12-26 12:33:48.13484	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzI0NTAsImV4cCI6MTc2OTMyNDQ1MH0.pcbCgrSyGQLjKzMcIxisl5SkSb_Nc2Kan3_NywjvKC0	2026-01-25 12:30:50.51	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 12:33:48.13
fa390952-2048-4278-84fe-58437fd1e0fc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 12:33:56.825175	2025-12-26 12:34:00.410464	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiZmExYzY1MS02ZDUxLTQxN2YtYThiZC0yMTMwZGQzYmMyOGMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzI2MzYsImV4cCI6MTc2OTMyNDYzNn0.ZEJXU-I1iOfJynQQ03qmztox5VCht1Zi1YGsjocw_3U	2026-01-25 12:33:56.82	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 12:34:00.406
96ea52dd-fb5f-43a2-98ec-05afe33fa048	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 12:34:13.501885	2025-12-26 12:34:16.073703	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0ZWNiNDE5Mi05ZTZhLTQxMGQtOWNjNS03MDM3YTVhMTA0ZWIiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzI2NTMsImV4cCI6MTc2OTMyNDY1M30.CWzFHzNAAkWi53NHtA4QUl8gsdtjJZBNX6s-lTWUEms	2026-01-25 12:34:13.5	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 12:34:16.072
b6e1a420-8889-4f5f-94b7-d047e4aa3252	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 12:48:35.926252	2025-12-26 13:40:59.295032	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzM1MTUsImV4cCI6MTc2OTMyNTUxNX0.ECIfiX3DdhjlcRqtG690CmFZGCvg-Dtd-ZULLjQGulQ	2026-01-25 12:48:35.923	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 13:40:59.294
5c32b936-38c6-42cc-a254-1160bac6ba8d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:04:52.753533	2025-12-26 13:40:59.295032	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzQ0OTIsImV4cCI6MTc2OTMyNjQ5Mn0.sdzsdM5oqjnODFUMOWQXIbj7AzthwUezMQgHNoqmmeU	2026-01-25 13:04:52.752	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 13:40:59.294
c6f4647a-a2a0-4005-abf5-82075cf9c71f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:24:00.745233	2025-12-26 13:40:59.295032	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzU2NDAsImV4cCI6MTc2OTMyNzY0MH0.jsRCrVxRcgJz9lwmuoQp6U4l-X5yzpSX5_iWoJ9vZWM	2026-01-25 13:24:00.744	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 13:40:59.294
8ac0f7cb-f8a2-4388-b31e-7b073dc925a1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:32:15.134545	2025-12-26 13:40:59.295032	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzYxMzUsImV4cCI6MTc2OTMyODEzNX0.DvuggiUY99C0cKya7yIDs6Y4ZKJQe0N5UZG-n0e43Zw	2026-01-25 13:32:15.133	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 13:40:59.294
ff7694ad-bcb8-4b72-b7e8-3b01ab855dcf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:37:26.635411	2025-12-26 13:40:59.295032	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzY0NDYsImV4cCI6MTc2OTMyODQ0Nn0.IGb8P0W8J-VVclkS0dYfx_A1iOgIOzro19Z5YthHdTs	2026-01-25 13:37:26.624	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 13:40:59.294
7331b6af-57a1-4542-a1c8-f166b6dfe930	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:37:46.780314	2025-12-26 13:40:59.295032	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzY0NjYsImV4cCI6MTc2OTMyODQ2Nn0.sTPm9uQTIlrcKpwr-d2NUnN1aIHCooVpbaITZFHOXZU	2026-01-25 13:37:46.779	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 13:40:59.294
24639396-7b83-47c6-8a9b-3ccfdee4fa2c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:38:04.242464	2025-12-26 13:40:59.295032	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzY0ODQsImV4cCI6MTc2OTMyODQ4NH0.ftyWKqrAAMuQ3R9Lsnyafi65aQ2DoLeCSyJXzk-buEo	2026-01-25 13:38:04.241	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 13:40:59.294
5b385882-a3c7-4dc8-810a-51e445cec8bf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:39:53.147144	2025-12-26 13:40:59.295032	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzY1OTMsImV4cCI6MTc2OTMyODU5M30.P5t88RQZ06igle-xMxEgJRHTP-V5dbNd8dh32RezJBM	2026-01-25 13:39:53.124	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 13:40:59.294
e16ce238-35d7-4348-a59d-07d3e16bab1b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:41:16.24956	2025-12-26 13:51:45.904908	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzY2NzYsImV4cCI6MTc2OTMyODY3Nn0.xSqIMbtvGlfXCA00PnL0PqA4RayyxnmLgt8_TogQfGc	2026-01-25 13:41:16.249	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 13:51:45.902
6ddc4db8-4c8f-452d-b3da-aeb1fda0a9f2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:51:55.823772	2025-12-26 13:59:28.803382	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzczMTUsImV4cCI6MTc2OTMyOTMxNX0.B7cYjThN3BRbptI6htOE6dVa5JrwBWWCNXObemOjumI	2026-01-25 13:51:55.821	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 13:59:28.798
dabcbea7-8597-46b6-ac21-bcb24221b829	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 13:59:43.363744	2025-12-26 13:59:53.536968	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3Mzc3ODMsImV4cCI6MTc2OTMyOTc4M30.62B0wc2EtGWVLUYz9HjNM3qcvmzfB1hhrF3C7Ln-Qc8	2026-01-25 13:59:43.363	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 13:59:53.536
caccad4b-3ed8-4e4f-b881-430d5c2cdadd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 14:00:05.885273	2025-12-26 14:07:44.676618	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3Mzc4MDUsImV4cCI6MTc2OTMyOTgwNX0.drPVbwfZ5x1ssc27FSov25nbAFbEpVVZNbcbn9br5_U	2026-01-25 14:00:05.885	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 14:07:44.668
c1448907-5272-45e5-9b6f-f24e0d382ba7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:21:43.636592	2025-12-26 15:22:19.855274	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDI3MDMsImV4cCI6MTc2OTMzNDcwM30.6n7_bYLI5aoxe8mpke0638xYqwJlEJmckUbwTSEvIOo	2026-01-25 15:21:43.625	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 15:22:19.85
98cdffa5-cd15-4c44-8e0a-f5705d032dde	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 14:07:53.165515	2025-12-26 15:29:26.119199	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3MzgyNzMsImV4cCI6MTc2OTMzMDI3M30.Fre5kxYu5AgzxhhSdoM1pbhWZqdQ4Ircp9TqdAWtrx4	2026-01-25 14:07:53.163	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 15:29:26.118
decd6481-b62a-4a7a-b9f7-ec5e13a91cbd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:29:18.564962	2025-12-26 15:29:26.119199	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDMxNTgsImV4cCI6MTc2OTMzNTE1OH0.hYDYnmZqrqEAQnhSlBPQyQvV65OHv8E_jbBYsx_w2tU	2026-01-25 15:29:18.563	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 15:29:26.118
17f8296f-e459-4f18-98db-54d7feca9b17	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:23:31.11641	2025-12-26 15:41:52.659114	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDI4MTEsImV4cCI6MTc2OTMzNDgxMX0.EEspuGOdL_BC4Y_v1C_y_hctMz2f0UfD4IFFa_7knOo	2026-01-25 15:23:31.115	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 15:41:52.658
f08f2786-87c7-492a-b0c8-9a0bfe29e2a5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:29:47.659949	2025-12-26 15:41:52.659114	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDMxODcsImV4cCI6MTc2OTMzNTE4N30.XiyxSdc0IgcLW-y6pypeqMPLGJTtIt2gngkduuqD7Fg	2026-01-25 15:29:47.659	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 15:41:52.658
50ec29c6-28b0-4ae8-9acb-08efc8555b48	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:37:40.853186	2025-12-26 15:41:52.659114	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDM2NjAsImV4cCI6MTc2OTMzNTY2MH0.jC43KlFRRSJQkA-ZRSiMeV0BNbeSn_LlqY8N4hv0dWo	2026-01-25 15:37:40.851	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 15:41:52.658
ae3f5124-6108-4729-b36d-a8a8f648c800	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:42:07.609234	2025-12-26 15:45:40.369886	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDM5MjcsImV4cCI6MTc2OTMzNTkyN30.aMkTqny_cFj0cFIwZik7-wuv__ZV_XLNhqByKpv7m0M	2026-01-25 15:42:07.608	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 15:45:40.369
993d6cc4-4c9e-4b24-b072-92559a779089	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:46:05.573289	2025-12-26 16:00:59.226186	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDQxNjUsImV4cCI6MTc2OTMzNjE2NX0.RlvNEVR7gJ787vsz-jy3LZucluZRt1rkalSoAsb17YQ	2026-01-25 15:46:05.572	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 16:00:59.224
2373a601-da1e-4f21-83bc-c77174079d53	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:01:19.446443	2025-12-26 16:01:30.95122	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDUwNzksImV4cCI6MTc2OTMzNzA3OX0.iuM0y2Vx0CJpC31W-_a5nk04zuAUB5V5CbC85Iax9h8	2026-01-25 16:01:19.445	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 16:01:30.949
c9f68256-0ca4-49f9-870b-c72949950f9d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:01:54.406439	2025-12-26 16:02:36.054621	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDUxMTQsImV4cCI6MTc2OTMzNzExNH0.PatBC12CSjgYCpG6qHUj4d2AAMlHQPvFgNa16YSxgdA	2026-01-25 16:01:54.406	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 16:02:36.054
f4de5f40-3219-4f88-b274-843cd89e1127	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:02:41.628411	2025-12-26 16:02:58.24325	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDUxNjEsImV4cCI6MTc2OTMzNzE2MX0.1gM1KCVKJUb1sDMrabA7twnHAHr5MMXAMZdvSOSp8s4	2026-01-25 16:02:41.628	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 16:02:58.243
610b7523-b07c-410a-a5b6-2fa3557a0150	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:03:26.122132	2025-12-26 16:04:04.751742	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDUyMDYsImV4cCI6MTc2OTMzNzIwNn0._6jAxc7vicfsDRfCIfMM32lkJkfzK1rpwPIhUhiJKts	2026-01-25 16:03:26.121	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 16:04:04.751
d3e119dc-4c38-422b-8962-1b9136d4bc48	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:04:16.207522	2025-12-26 16:05:55.244599	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDUyNTYsImV4cCI6MTc2OTMzNzI1Nn0.Ka8NWXvgm6QV5eS7dkuGPwlJKZYb96QDfyd5tNRC8dE	2026-01-25 16:04:16.207	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 16:05:55.244
1b8daa01-d6fa-45c5-b6da-0cb70e4ae33b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:06:22.195517	2025-12-26 16:09:15.045316	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDUzODIsImV4cCI6MTc2OTMzNzM4Mn0.krtX9ddXSnALRyvs3vhAOouRRryxtq8qFguq9XGcxtE	2026-01-25 16:06:22.194	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 16:09:15.045
380f6667-fcae-4ed0-8516-17a3b789ef43	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:09:22.777561	2025-12-26 16:09:39.98431	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDU1NjIsImV4cCI6MTc2OTMzNzU2Mn0.BG8F8Sq-v6OKIX3AwXY8aXgt0qrLhGCs83aXzJk79xU	2026-01-25 16:09:22.777	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 16:09:39.984
a7a76a7b-c804-4afc-8e45-6396453286bb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:10:09.087667	2025-12-26 16:10:22.036043	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDU2MDksImV4cCI6MTc2OTMzNzYwOX0.IaHWxTpjk1iOFzQXK5KjiSalgSLwHei8195SGwYJK5Y	2026-01-25 16:10:09.087	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 16:10:22.035
c88ec144-c0b6-43bb-94e8-4fb8ccd740df	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:10:29.559348	2025-12-26 16:10:46.766211	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDU2MjksImV4cCI6MTc2OTMzNzYyOX0.tS2Yk2W4O4rBxPgSpVrrn74Pch32Xe8aPTDhijbFLp4	2026-01-25 16:10:29.559	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 16:10:46.765
a6e81a21-e00f-4817-8112-1b931a4d9c05	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:14:42.959149	2025-12-26 16:17:10.231624	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDU4ODIsImV4cCI6MTc2OTMzNzg4Mn0.T9zLL8LGXO8lOTvV30AW5T1tZbO4tz-5IOF4o-egPJw	2026-01-25 16:14:42.957	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 16:17:10.23
3013d344-ca46-4f6b-9e20-0f2350705416	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:20:51.384957	2025-12-26 16:21:05.09554	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDYyNTEsImV4cCI6MTc2OTMzODI1MX0.J1ffShppIAiV1kzxvo8ECeBUawAT_RsvErwru8YBcsc	2026-01-25 16:20:51.384	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 16:21:05.095
3a5a3014-fba6-479f-b490-f99f7bc830b2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:43:33.677786	2025-12-26 17:01:27.913077	d105993f-6f85-4144-ba14-dd361ae6df2e	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkMTA1OTkzZi02Zjg1LTQxNDQtYmExNC1kZDM2MWFlNmRmMmUiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDc2MTMsImV4cCI6MTc2OTMzOTYxM30.D949bVZmPzv4FiA2ursNk3T9bMrmai22SYnHHBfJKKY	2026-01-25 16:43:33.677	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 17:01:27.912
53f9d623-4348-43ae-b085-fd5183a3aadb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:33:01.014045	2025-12-26 17:43:07.607159	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDY5ODEsImV4cCI6MTc2OTMzODk4MX0.IDcnx2I2UDPo7pJRt_6NAg3-KFaGSdFNmN8Cd35Lv1I	2026-01-25 16:33:01.013	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 17:43:07.606
bf374173-8460-48ef-a57b-275b4f14bbdd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:11:16.035717	2025-12-30 17:29:53.23625	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDU2NzYsImV4cCI6MTc2OTMzNzY3Nn0.RwzC70gj6M-8gcSeQnCDvnV0axizRg20xAj_cyl7e3k	2026-01-25 16:11:16.035	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-30 17:29:53.232
bedab8cf-e830-4fa3-b0cf-f4edc69a7efe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:50:19.55554	2025-12-26 16:55:54.079088	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDgwMTksImV4cCI6MTc2OTM0MDAxOX0.a5htZsAImYsfQLBKvecsmUvhG4tanfsgVsd_lFrCZ34	2026-01-25 16:50:19.555	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 16:55:54.076
8099d292-7569-4255-bbc9-0bd4b3ba811e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:56:06.563326	2025-12-26 17:01:27.913077	d105993f-6f85-4144-ba14-dd361ae6df2e	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkMTA1OTkzZi02Zjg1LTQxNDQtYmExNC1kZDM2MWFlNmRmMmUiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDgzNjYsImV4cCI6MTc2OTM0MDM2Nn0.-dsNE9mmJPYwn8rvZdPxSkcQ69wdF__QCW8hLtfdpZw	2026-01-25 16:56:06.561	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 17:01:27.912
f15d9804-c6ab-44f4-ae96-24296446645e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:01:53.279414	2025-12-26 17:02:07.57517	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDg3MTMsImV4cCI6MTc2OTM0MDcxM30.w69YTBgEZr6dLVmYb-BmOiFLn890dTZfyNk8vltfhXo	2026-01-25 17:01:53.278	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 17:02:07.574
65b47a14-87ad-4d7c-a475-5f51346b0adc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:02:26.029177	2025-12-26 17:04:41.415625	d105993f-6f85-4144-ba14-dd361ae6df2e	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkMTA1OTkzZi02Zjg1LTQxNDQtYmExNC1kZDM2MWFlNmRmMmUiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDg3NDYsImV4cCI6MTc2OTM0MDc0Nn0.Gq4ok7C3psxpTO2qM0SE83zJyIC0_FSCb6OAO8T7GX0	2026-01-25 17:02:26.028	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 17:04:41.412
4f27e7ad-0537-4ecf-b203-e76dab725f8c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:48:47.6625	2025-12-26 17:43:07.607159	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDc5MjcsImV4cCI6MTc2OTMzOTkyN30.bfb9nOm2Li-dI-g4Fa-Ysfa_nWOCWTxxHU3cqsoUmqw	2026-01-25 16:48:47.661	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 17:43:07.606
c96da450-856b-4e9d-8680-976da933908c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:17:07.551052	2025-12-26 17:46:31.506908	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzODY2YzUxZi1hNWRiLTQ3YzQtYTRlZi1jMmVkNzVlZWM3ZjQiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDk2MjcsImV4cCI6MTc2OTM0MTYyN30.auo7-zJvE1WbL-lsv5b2KAv4uaxPq0kHHhQGez194_Y	2026-01-25 17:17:07.55	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 17:46:31.506
d7fd77af-1dfc-44e5-af71-d93abf34cc3c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:19:58.685983	2025-12-26 17:48:13.343066	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDk3OTgsImV4cCI6MTc2OTM0MTc5OH0.yw_l-bOqnMBkthSO0vOABPv0BW1XKnZdkWxXAAwIYUk	2026-01-25 17:19:58.685	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-26 17:48:13.342
b15d33aa-fc08-4958-ae08-2eca48d7630c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:08:47.025479	2025-12-26 17:43:07.607159	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDkxMjcsImV4cCI6MTc2OTM0MTEyN30.sAwz1vdowVpNDxGw8ST8lzbMm-pBqxQNwbxAuvsRdpc	2026-01-25 17:08:47.024	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 17:43:07.606
8a63955f-ae83-4759-abdc-5fd51fb0b06b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:18:52.699977	2025-12-26 17:43:07.607159	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NDk3MzIsImV4cCI6MTc2OTM0MTczMn0.WN2M_o6F-jyZ1P8JSsLz-3PKBZmGGXYOVc0gfEphNfs	2026-01-25 17:18:52.699	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 17:43:07.606
79f5ea31-2d2a-4a5b-a3eb-9ea98ddfebf6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:32:14.220939	2025-12-26 17:43:07.607159	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTA1MzQsImV4cCI6MTc2OTM0MjUzNH0.nUSj0oI1pKamD4WOulZOhEFWAU5VShmBGf5AOnZbRSU	2026-01-25 17:32:14.22	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 17:43:07.606
06d6787c-19b8-4055-a3ce-a9b2c878393f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:44:05.191364	2025-12-26 17:46:31.506908	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzODY2YzUxZi1hNWRiLTQ3YzQtYTRlZi1jMmVkNzVlZWM3ZjQiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTEyNDUsImV4cCI6MTc2OTM0MzI0NX0.392N-VJyLYO0n8SbAamve0yep3PHySetpHwqUTJrEUA	2026-01-25 17:44:05.191	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 17:46:31.506
59a1b59e-8af1-44a9-ada3-da8d8598ed81	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:46:40.070038	2025-12-26 17:47:05.419512	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTE0MDAsImV4cCI6MTc2OTM0MzQwMH0.OTZOe4KUhF2R-rBg_tkVGeaAAB47i3krQVG9Ofv-1tw	2026-01-25 17:46:40.069	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 17:47:05.417
b9e26505-48fe-459e-b70f-ce972a9c8136	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:47:34.513663	2025-12-26 17:48:13.343066	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTE0NTQsImV4cCI6MTc2OTM0MzQ1NH0.0lvMLlLmkv7IxKBYgTjM8GjqIgEU4ONkb8_KEIW-1LQ	2026-01-25 17:47:34.513	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 17:48:13.342
666a8b75-0e84-4cf7-92bf-a411a6259897	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:48:27.675396	2025-12-26 17:48:42.315773	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTE1MDcsImV4cCI6MTc2OTM0MzUwN30.R2TGfi3SoEk8l0K1NODHIK1_H0zvf_QYGSsgYMzaT5g	2026-01-25 17:48:27.675	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 17:48:42.315
13411d14-afce-498f-8f9c-6f401a314776	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:48:51.760153	2025-12-26 17:49:12.826323	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzODY2YzUxZi1hNWRiLTQ3YzQtYTRlZi1jMmVkNzVlZWM3ZjQiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTE1MzEsImV4cCI6MTc2OTM0MzUzMX0.47x6Cu4gAc-KrJ2-gMzMSetrgV7c-MRgTCy0Ug7Q2mo	2026-01-25 17:48:51.759	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-26 17:49:12.825
e67456a9-6eba-4c9c-8ad6-3c0e735ed96c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:12:41.76971	2025-12-26 18:12:41.76971	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzODY2YzUxZi1hNWRiLTQ3YzQtYTRlZi1jMmVkNzVlZWM3ZjQiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTI5NjEsImV4cCI6MTc2OTM0NDk2MX0.xZn65BeD5QeasaXq0EX6PyNrlOukTHOFrsIE6QhHeJo	2026-01-25 18:12:41.769	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N
9dcb8386-2195-4eed-b159-e748432ef853	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:06:27.200301	2025-12-30 12:41:50.659092	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTI1ODcsImV4cCI6MTc2OTM0NDU4N30.7xXCI_QdRM4Qps8I76qfwHVlXOGmdmzXkuu6sG6aBGw	2026-01-25 18:06:27.199	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 12:41:50.658
9ab3a7fc-0613-4a88-aac8-64236d7351f3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:21:22.544015	2025-12-26 18:21:22.544015	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5MDljYjFmMC1lYzNkLTQyMTgtYjJmZi05NmJhYzQ0ZTViYjAiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTM0ODIsImV4cCI6MTc2OTM0NTQ4Mn0.Hp79HAlU-oV-Qc-U5IFdUwLOUzzIaVI5k27-irStXPg	2026-01-25 18:21:22.543	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N
7b352248-5b6d-4a5d-84ad-8e27b76f84c3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-29 15:49:43.83955	2025-12-29 16:21:05.230622	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwMDM1ODMsImV4cCI6MTc2OTU5NTU4M30.fHlCCaWHJBlIgxDELZAPeB2josq2XaddvfwAypa_hf4	2026-01-28 15:49:43.837	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-29 16:21:05.23
086358fb-3029-45a7-9d6a-9d733efa079e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 10:34:10.217822	2025-12-30 11:07:53.554186	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzEwNTAsImV4cCI6MTc2OTY2MzA1MH0.CNwrUh5AAhMce4nPD0ImUSLfEz2c7DjVYGb9llrjLGo	2026-01-29 10:34:10.216	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 11:07:53.553
d9fe431f-86a4-49d6-a032-acb3594ddee6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 11:07:53.529702	2025-12-30 11:24:06.091004	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzMwNzMsImV4cCI6MTc2OTY2NTA3M30.tF1XMkClf4n7cyqWrrLZXcYaHWXud9WlIFaQ2-Ih_e8	2026-01-29 11:07:53.527	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-30 11:24:06.09
8d5a4a0c-84bc-4743-aef3-957689a7ad59	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 11:24:06.058607	2025-12-30 11:42:37.382854	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzQwNDYsImV4cCI6MTc2OTY2NjA0Nn0.tdtPtiiRQg09MHpfNX019YrEqGS_z8WQq0OkPKSLpxs	2026-01-29 11:24:06.048	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-30 11:42:37.381
52f8e6e2-ffc5-46e3-8645-5bc50ef4ba64	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 11:56:00.622835	2025-12-30 12:11:18.373583	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzU5NjAsImV4cCI6MTc2OTY2Nzk2MH0._u80gRovcdyOB7oVqcHQHV2rkdop3qi2Xe5K5xUK--0	2026-01-29 11:56:00.621	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 12:11:18.373
02b24e4a-3fb4-462e-b5dc-ccc351a6bc86	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:11:18.367097	2025-12-30 12:26:50.016814	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzY4NzgsImV4cCI6MTc2OTY2ODg3OH0.UuLjYCHEVS4KcMvFUloYzHIiMnASKUUxCZpayzCy80s	2026-01-29 12:11:18.366	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-30 12:26:50.015
9c20d4d6-b6db-424d-8e90-6f02075e9624	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:23:28.367979	2025-12-30 12:41:50.659092	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjY3NTM2MDgsImV4cCI6MTc2OTM0NTYwOH0.S5TZqirB3ErHhAIr9QmJczsu7gfXE_PBM-JZk5AV4Eo	2026-01-25 18:23:28.367	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 12:41:50.658
755605dc-ad90-4fb3-836f-d9ae92ce7a77	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 11:42:37.373922	2025-12-30 12:41:50.659092	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzUxNTcsImV4cCI6MTc2OTY2NzE1N30.YvZ_Go-QlpQsVmlmlvCc0sd8apfp2fjPAqzeSI-eC5w	2026-01-29 11:42:37.372	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-30 12:41:50.658
15e8e4cd-a693-41c4-837e-a899c422edf4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:26:49.999251	2025-12-30 12:41:50.659092	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzc4MDksImV4cCI6MTc2OTY2OTgwOX0.zvKJxCKEtTAsnCf_GMJtCjuiUQYKHyu4-F6FVnnnan4	2026-01-29 12:26:49.996	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-30 12:41:50.658
f13595b1-b48b-4c3c-9a4e-22f51d521c47	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-29 15:32:45.837445	2026-01-01 07:16:45.635704	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwMDI1NjUsImV4cCI6MTc2OTU5NDU2NX0.0qKFVJko7TER1MAvGLAB4tT2YIYFdAAMSO1WcNmBUBY	2026-01-28 15:32:45.836	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 07:16:45.635
0992f941-864f-4bb8-8c08-a8bcc47734b7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-29 16:21:05.204894	2026-01-01 07:16:45.635704	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwMDU0NjUsImV4cCI6MTc2OTU5NzQ2NX0.U9W1DCPAUF9FiB2r9-_1FGISNBW6JcgiYdM8zb5GZOQ	2026-01-28 16:21:05.203	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 07:16:45.635
517efa23-2c9f-472e-95e1-412e2c8e2162	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:34:57.794202	2025-12-30 12:41:50.659092	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzYjFmNmI3My1jYzAyLTQ2MjctYWU4My04ZTFlYmM1NjE2ZWMiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzgyOTcsImV4cCI6MTc2OTY3MDI5N30._KggZTzQ-Jr5TeEItbk6D_brFeEj2QNpB4uPQ_F2jME	2026-01-29 12:34:57.788	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 12:41:50.658
9a9b6d81-0f0b-4d87-9c50-9594039ef85b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:42:15.571906	2025-12-30 12:42:15.571906	1d97134a-1b6a-47da-b3da-9324aa1a2f69	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxZDk3MTM0YS0xYjZhLTQ3ZGEtYjNkYS05MzI0YWExYTJmNjkiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzg3MzUsImV4cCI6MTc2OTY3MDczNX0.6MjA_hfapltbNFbC5rNfxP6ywAZGyq6kaTv4OEXMi4s	2026-01-29 12:42:15.571	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N
74169fe7-6577-4719-b0e1-e17725f42352	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:43:54.976706	2025-12-30 13:00:46.078962	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzODY2YzUxZi1hNWRiLTQ3YzQtYTRlZi1jMmVkNzVlZWM3ZjQiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzg4MzQsImV4cCI6MTc2OTY3MDgzNH0.pcheGMYTJ8bpsJ4Qa_Gcep4wEiH3CCjn5oe_3GPBR-M	2026-01-29 12:43:54.976	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2025-12-30 13:00:46.078
75c9ce65-6197-40d7-a08a-43cab067a9d0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 13:31:47.354333	2025-12-30 13:31:47.354333	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzODY2YzUxZi1hNWRiLTQ3YzQtYTRlZi1jMmVkNzVlZWM3ZjQiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwODE3MDcsImV4cCI6MTc2OTY3MzcwN30.ZYQXVeWcdxns2yv-GYi-bsFdOfA_p0R7ngsjIO6aquc	2026-01-29 13:31:47.353	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	\N
38c6b77d-8969-4ddb-86e6-a7973ed3e66d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 13:00:46.070752	2025-12-30 13:31:47.361188	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzODY2YzUxZi1hNWRiLTQ3YzQtYTRlZi1jMmVkNzVlZWM3ZjQiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwNzk4NDYsImV4cCI6MTc2OTY3MTg0Nn0.vZMa1dIERW0mk_V70L1GtW6DM6cKeq7TOfCrBFRHNSE	2026-01-29 13:00:46.07	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2025-12-30 13:31:47.36
b4b6037d-ca18-49d4-8a79-a01129f945a9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:28:33.770137	2025-12-30 17:29:53.23625	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTU5MTMsImV4cCI6MTc2OTY4NzkxM30.oUCNOG6HSyRLImoPkPwcSCwvE9QP6EuO04p9YM3BT_c	2026-01-29 17:28:33.76	::1	curl/8.7.1	2025-12-30 17:29:53.232
705d82a5-8aef-4d8c-9572-ea02ad136dd8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:29:37.501005	2025-12-30 17:29:53.23625	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTU5NzcsImV4cCI6MTc2OTY4Nzk3N30.NDUWOjM-RNvVH6oThohUnhR5VPTH_OysttxS0W59bIg	2026-01-29 17:29:37.498	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 17:29:53.232
df00a049-7f92-4091-88a8-6ff6c989ce56	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:30:00.17526	2025-12-30 17:30:53.470026	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTYwMDAsImV4cCI6MTc2OTY4ODAwMH0.sM93IgAqR8A3boSK1sWGAsiqS945SpJP3jBxHgzInpo	2026-01-29 17:30:00.173	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 17:30:53.469
646bc9fa-3aa2-44ea-8596-f889e45a88c5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:18:51.670407	2026-01-01 07:16:45.635704	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTUzMzEsImV4cCI6MTc2OTY4NzMzMX0.1VZYKVG5kV_TKriURnKw48YLHH3q_GuUIseKNyfi6pA	2026-01-29 17:18:51.668	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 07:16:45.635
5ebf3abd-cc20-44af-8596-6aa10c54a825	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:30:47.235201	2025-12-30 17:30:53.470026	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTYwNDcsImV4cCI6MTc2OTY4ODA0N30.tDJlBYQVnhXeiG9EOoNVF7a-4nWvNcAEhUh28cTWPLE	2026-01-29 17:30:47.234	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 17:30:53.469
c7638cb3-82fa-450a-a09e-a0504780eec6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:51:52.644931	2025-12-30 18:07:33.950794	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTczMTIsImV4cCI6MTc2OTY4OTMxMn0.5EnMCBKEGNEqI2MTYRt1cxXsLi4WsHwMitWrGsrvXC0	2026-01-29 17:51:52.642	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-30 18:07:33.936
402566e9-89f2-46dd-83ab-c26443c0a3e5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:11:56.423398	2025-12-31 09:26:58.679534	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNTI1MTYsImV4cCI6MTc2OTc0NDUxNn0.b_lBB6iQu0EdnK3rJBywZoBKTAiQm2W5Bw-AS4ojN_4	2026-01-30 09:11:56.421	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 09:26:58.679
dd417914-6d00-45db-a6d3-5540a8c3f584	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:26:58.673959	2025-12-31 09:44:12.60473	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNTM0MTgsImV4cCI6MTc2OTc0NTQxOH0.U01WhdHnmyDrueFa-W0cTg6Kseipv-iYTreCKmoS7ao	2026-01-30 09:26:58.673	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 09:44:12.604
eda13184-29dd-4088-9161-16b86fe78a86	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:32:15.567083	2025-12-31 09:55:39.441692	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTYxMzUsImV4cCI6MTc2OTY4ODEzNX0.FOdqUppuKnpMYBcktU_HFG6GLDZ8PVmMxkSBdi-iv34	2026-01-29 17:32:15.566	::1	curl/8.7.1	2025-12-31 09:55:39.441
68a29df4-b2e4-49f3-8934-25e156e1a46f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:33:13.226714	2025-12-31 09:55:39.441692	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTYxOTMsImV4cCI6MTc2OTY4ODE5M30.XoLLNakM-Ur9sFC-tp2G59UlZr8uVkLMXhQLnNWYu1s	2026-01-29 17:33:13.225	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 09:55:39.441
62349a47-f5f4-40a9-b2b7-7334e20c3603	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:55:08.344267	2025-12-31 09:55:39.441692	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTc1MDgsImV4cCI6MTc2OTY4OTUwOH0.-84awLfJlNBLHE0NqlbppvTH_t4nTVYSUQVBiYQ8EbM	2026-01-29 17:55:08.342	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 09:55:39.441
4067cd6f-cde8-4506-a8c2-36cda5dce534	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:44:12.595572	2025-12-31 09:55:39.441692	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNTQ0NTIsImV4cCI6MTc2OTc0NjQ1Mn0.7rQcohhuRu3KZzOZn_wcsJvzRXM-jI6e7KYzfkXgQ1M	2026-01-30 09:44:12.594	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 09:55:39.441
e07a1ce3-3332-469f-8e53-2ba00a7f9f62	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:07:33.807346	2026-01-01 07:16:45.635704	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcwOTgyNTMsImV4cCI6MTc2OTY5MDI1M30.LBSN0GYdQ2rpsr0i27x9LYlibDbe2SovDVI-teBXcGY	2026-01-29 18:07:33.805	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 07:16:45.635
95f8532e-925f-4a4d-a4dc-b707a34357ea	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:56:35.607576	2025-12-31 09:58:40.083444	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNTUxOTUsImV4cCI6MTc2OTc0NzE5NX0.9reNgfMP0_FpG7VrlLCH-1LkKmc_vq7o3XS5l9FSZF4	2026-01-30 09:56:35.607	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 09:58:40.081
144fa5b6-00d6-4fe9-adca-675684839ece	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 09:59:13.262325	2025-12-31 10:00:45.721643	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNTUzNTMsImV4cCI6MTc2OTc0NzM1M30.ZIm8Ohq2gflwwAEfHiH-yu7FdI8YeUbpfjbKuNuJSMo	2026-01-30 09:59:13.261	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 10:00:45.72
517d810c-6bdf-4ab7-9832-8aeeb4ddfbe1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:00:22.830823	2025-12-31 10:00:45.721643	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNTU0MjIsImV4cCI6MTc2OTc0NzQyMn0.eOEGRUeZY_T2umfeGsdH8xEtAyrjVeec1mDFGD0J32o	2026-01-30 10:00:22.828	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 10:00:45.72
77bfab7d-5edb-4af9-9abd-ba1c4c8c5cc7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 12:35:16.191927	2025-12-31 12:42:52.50637	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNjQ3MTYsImV4cCI6MTc2OTc1NjcxNn0.xkPBX40nu2nB1mQsD1A3Pf1OBAfkCNoDxdpM8Ogsl3M	2026-01-30 12:35:16.19	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 12:42:52.505
635ea6fa-41d3-48df-a901-e16a67cd368f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 12:50:42.721716	2025-12-31 13:06:29.370424	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNjU2NDIsImV4cCI6MTc2OTc1NzY0Mn0.3MXn_gIB40lCaUDajPvXAiR5KEbrqdE0Yl7uziU2xsY	2026-01-30 12:50:42.721	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 13:06:29.37
0560423d-6a95-410f-9e98-3e3711f07682	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 13:06:29.357053	2025-12-31 13:21:31.61524	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNjY1ODksImV4cCI6MTc2OTc1ODU4OX0.F_P9OJ6hqwnhZphF0gb5EsP4a_I4C2eGnpItunX_JlI	2026-01-30 13:06:29.356	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 13:21:31.615
611ca0b7-3084-478f-8932-0b600c492689	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 13:21:31.608503	2025-12-31 13:41:07.142626	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNjc0OTEsImV4cCI6MTc2OTc1OTQ5MX0.xUk9xARYSyTOl6quxWYdv97DLy9WUipgZ0tkEtR-uhA	2026-01-30 13:21:31.608	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 13:41:07.142
fd35d6d3-daeb-4bf1-acb9-10e582f1e291	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 18:49:13.757389	2025-12-31 19:26:56.37337	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxODcxNTMsImV4cCI6MTc2OTc3OTE1M30.pwTWSKTM10AXJ9IOynJbixrQeMWFxSVscbMiPzHOgSw	2026-01-30 18:49:13.756	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 19:26:56.373
2695d1a0-68d8-48af-b1cc-5a2e5e9d35bb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 12:43:10.120851	2025-12-31 19:26:57.709909	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNjUxOTAsImV4cCI6MTc2OTc1NzE5MH0.iwxbcbKYsUc1vgQmuPK9c8o2sF-nDb_0UFY2IKCO3eY	2026-01-30 12:43:10.12	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 19:26:57.704
b6504f39-7f51-4452-a14e-cd89fbaed488	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 13:41:07.137863	2025-12-31 19:26:57.709909	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNjg2NjcsImV4cCI6MTc2OTc2MDY2N30.7EQKQPTk2irNpawDJDfb3IM0mzN4WIDi3GzZTXG_AeA	2026-01-30 13:41:07.137	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 19:26:57.704
eab98a1a-06f9-4689-a0d8-260d610c4bef	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:01:16.625392	2026-01-01 07:16:45.635704	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxNTU0NzYsImV4cCI6MTc2OTc0NzQ3Nn0.pUCVF10pAHw2NSeurOVTkQ90M_8czhalnuL_kUIAwgs	2026-01-30 10:01:16.623	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 07:16:45.635
da7b5f55-ad73-453d-8433-3da2a809040f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 19:26:56.342711	2025-12-31 19:26:57.709909	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcxODk0MTYsImV4cCI6MTc2OTc4MTQxNn0.IxyY1UKZYI8QzG_eEbtk-FWzKtEwJLJjkLPdrgn2r_U	2026-01-30 19:26:56.342	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-31 19:26:57.704
7bd19e2c-94f2-4d70-bf20-9c7cf02bcef0	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 06:43:21.290092	2026-01-01 06:58:31.641631	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzAwMDEsImV4cCI6MTc2OTgyMjAwMX0.quo8KT5mohuszU6MRsWVvjeNiwyWPrpyWa3H8phcwjM	2026-01-31 06:43:21.288	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 06:58:31.641
9f6c2f17-ee5e-4150-b006-c98b72a3119b	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 06:58:31.637268	2026-01-01 07:16:45.635704	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzA5MTEsImV4cCI6MTc2OTgyMjkxMX0.EDkiDo6F7BqCnYgcAWtYdgBi0SIQXrT8H-1-17DPEGQ	2026-01-31 06:58:31.636	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 07:16:45.635
407a995a-ae74-4dfb-8fa4-4fb6540f7968	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:13:46.576039	2026-01-01 07:16:45.635704	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzE4MjYsImV4cCI6MTc2OTgyMzgyNn0.xdqxfO9KFJNjMzR71HOZqkE5-TI7_ww_F6D53A0jmig	2026-01-31 07:13:46.575	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 07:16:45.635
934794af-4b3e-4e71-b897-203e7d4600c6	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:16:57.334362	2026-01-01 07:22:20.545693	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzIwMTcsImV4cCI6MTc2OTgyNDAxN30.-aQua0e4Bb5xtCLpeERXwhaTb4p1TH2-YY55nHddf9Y	2026-01-31 07:16:57.334	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 07:22:20.544
3527863a-b92f-4607-9405-42214e5d7117	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:22:37.611642	2026-01-01 07:30:11.366918	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzIzNTcsImV4cCI6MTc2OTgyNDM1N30.fyIJyMV313YFJJPhPorW7wVrvgCbqdLP3TKSyh3Ahrg	2026-01-31 07:22:37.61	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 07:30:11.363
0d215ae3-73a6-44b4-8132-fbad675d89df	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:23:53.021275	2026-01-01 07:30:11.366918	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzI0MzMsImV4cCI6MTc2OTgyNDQzM30.cktNmmrSsk_W9jvTP9MRwksBtl4lsSo6hYR4ZcVF_1A	2026-01-31 07:23:53.019	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 07:30:11.363
dc2bb1b4-c1c1-4735-b804-4e69d0e668b6	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:30:29.636746	2026-01-01 07:30:33.611643	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzI4MjksImV4cCI6MTc2OTgyNDgyOX0.COPh_EOSjp2JVLcGR5uETAx4qec_7ykvclMQ8UW2eCc	2026-01-31 07:30:29.635	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 07:30:33.611
35a042fe-d38c-4eb5-9165-c3b6621387c1	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:34:12.546564	2026-01-01 07:53:59.498198	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzMwNTIsImV4cCI6MTc2OTgyNTA1Mn0.75RQqMfbrGMXzuBjO3g6gDD_z-8qP4sZ0rgMY29crbQ	2026-01-31 07:34:12.546	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2026-01-01 07:53:59.494
dbdaea44-f850-4594-966e-523ac9d9b455	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:46:08.450799	2026-01-01 07:53:59.498198	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzM3NjgsImV4cCI6MTc2OTgyNTc2OH0.dOkLwp0otrXcLnJaRqbqVZap_Ty8aeCboYCRlyENkwo	2026-01-31 07:46:08.449	::1	Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 07:53:59.494
66f0542e-0bee-4812-99ca-4dfea102ca49	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:56:29.790625	2026-01-01 08:11:54.011635	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzQzODksImV4cCI6MTc2OTgyNjM4OX0.f_sUrnimKw4meSRm4XgUaNOwM3m7626KYTWIwa1Fhfo	2026-01-31 07:56:29.789	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2026-01-01 08:11:54.011
24c46bf5-9c32-4519-b9b7-c1f862bb85d2	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:11:54.005718	2026-01-01 08:28:40.589907	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzUzMTQsImV4cCI6MTc2OTgyNzMxNH0.opBO6zj_17qnsCSypJeZ1XTGuvGgVn7by5GO6QT3-UA	2026-01-31 08:11:54.005	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2026-01-01 08:28:40.589
ae2675c0-8ac9-40fc-9082-4f74f91b04f5	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:28:40.581823	2026-01-01 08:30:49.686801	95791439-c679-4dec-98cf-1eccedd65a87	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NTc5MTQzOS1jNjc5LTRkZWMtOThjZi0xZWNjZWRkNjVhODciLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzYzMjAsImV4cCI6MTc2OTgyODMyMH0.v4MUFL75Ik_6IWnk2L587a8_xkTSMZauxGQYd4XDb4k	2026-01-31 08:28:40.58	::1	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	2026-01-01 08:30:49.686
7c82a71e-968e-49ac-8a45-93b597c0ca0e	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:47:09.683485	2026-01-01 08:47:09.683485	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzc0MjksImV4cCI6MTc2OTgyOTQyOX0.46YMxaQSDzoZ6tYDLIHuKaHSqPymZ66pfn9UovM7WHU	2026-01-31 08:47:09.68	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	\N
0e5a8a6e-262f-4c0a-a790-54247b641a7f	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:31:24.225821	2026-01-01 08:47:09.757657	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzY0ODQsImV4cCI6MTc2OTgyODQ4NH0.5n2bgD6Pqv7ifwPPpnhwufP-rVO516OuuxuEJa2LFVA	2026-01-31 08:31:24.225	::1	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36	2026-01-01 08:47:09.744
7b22945c-b8c7-4e7d-a343-ede388b2103c	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:57:08.263744	2026-01-01 09:12:23.295822	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzgwMjgsImV4cCI6MTc2OTgzMDAyOH0.u9EQbrPOEk0zGbfVLb1ytxTAk9nY0No_O07RUbzhg-w	2026-01-31 08:57:08.263	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 09:12:23.295
6c5ecf30-79d0-403a-90fb-b4bf9b6d311a	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:12:23.289902	2026-01-01 09:27:24.212657	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzg5NDMsImV4cCI6MTc2OTgzMDk0M30.nyY0GNgWDJiyRYjaOvo9Gcu2ip44y-2eS14Q9CXt9fE	2026-01-31 09:12:23.289	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 09:27:24.212
a73a5710-820f-4d04-ba44-2c2b3201f378	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:24.209861	2026-01-01 09:42:48.33692	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyMzk4NDQsImV4cCI6MTc2OTgzMTg0NH0.c3RNat9q65DaDUhNmt587sxbw4RGPPWIMdkzJ77rt1g	2026-01-31 09:27:24.209	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 09:42:48.336
eb76f435-e18e-4789-a1c2-7c128f2b92a0	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 10:02:06.545198	2026-01-01 10:02:06.545198	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyNDE5MjYsImV4cCI6MTc2OTgzMzkyNn0.U26caW0GJtSPBorP27GNC53Sc_6spmv81rN1OjNqZtk	2026-01-31 10:02:06.544	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N
fca4fad6-bb71-43da-b3e7-ca0be2474851	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:42:48.327831	2026-01-01 10:02:06.577687	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyNDA3NjgsImV4cCI6MTc2OTgzMjc2OH0.O_9kDcgPrBLAtIr_UK5o164ex8tTl32ATF_Y4r0bBrQ	2026-01-31 09:42:48.327	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 10:02:06.577
7933ef3b-1eed-4559-86d2-d8c459153468	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 10:32:16.177351	2026-01-01 11:23:50.177869	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyNDM3MzYsImV4cCI6MTc2OTgzNTczNn0.lqCxDAYPI2Y6MrKzGYZ8ebtwP9oAVun3fXFzCHt672A	2026-01-31 10:32:16.177	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 11:23:50.177
755f9fe2-26d9-4326-aa6f-de11566a6842	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 11:39:00.24841	2026-01-01 11:39:00.24841	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyNDc3NDAsImV4cCI6MTc2OTgzOTc0MH0.f_HE3mqcyss7yvSRurYDeaLS2wGyaCb_RkwTRrI21jc	2026-01-31 11:39:00.248	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N
0d4da6e6-413b-4500-99e2-f6d8c5102e87	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 11:23:50.169375	2026-01-01 11:39:00.253307	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyNDY4MzAsImV4cCI6MTc2OTgzODgzMH0.0sRu21ZkaxFqysu4hAZcylCPW9-FxVnDQRuITB1Gs_g	2026-01-31 11:23:50.169	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-01 11:39:00.253
f987a6a0-665e-456f-b261-b2bc827146d0	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 12:49:52.26664	2026-01-01 12:49:52.26664	44142ebb-779d-4e83-b0a2-3db691e389ff	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NDE0MmViYi03NzlkLTRlODMtYjBhMi0zZGI2OTFlMzg5ZmYiLCJjb21wYW55SWQiOiJlYjc1YTY1Yi0wNTVmLTQ0MDgtYTU4Yy03MWQyMzM0NDNjMTciLCJpYXQiOjE3NjcyNTE5OTIsImV4cCI6MTc2OTg0Mzk5Mn0.O18cyQZBky2XWJjd-YD1GtOnH0DKwu9RyhA-Ocs5m_w	2026-01-31 12:49:52.266	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N
\.


--
-- TOC entry 4383 (class 0 OID 65552)
-- Dependencies: 221
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (id, company_id, created_at, updated_at, role_id, permission_id) FROM stdin;
\.


--
-- TOC entry 4384 (class 0 OID 65564)
-- Dependencies: 222
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, company_id, created_at, updated_at, name, description, hierarchy_level, parent_role_id) FROM stdin;
cc869775-11cb-4a30-a846-79edbe15812d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	TENANT	Tenant - Villa resident	10	\N
7a712638-c3cf-47e3-9bd2-43312f93a669	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ADMIN	Administrator - Full access	100	\N
9ea16b07-ccf5-424f-be93-640f37b809a4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	SITE_COORDINATOR	Site Coordinator - View all, assign department, schedule	80	\N
70dd98cb-2806-4079-ad98-c4d605611e58	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	SUPERVISOR	Supervisor - Assign technicians, update work status	60	\N
08c8a61a-a9eb-489d-a603-dfadcb1e8618	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:05:26.002095	2025-12-24 13:05:26.002095	TECHNICIAN	Technician - Update assigned tickets, add work notes	30	\N
\.


--
-- TOC entry 4373 (class 0 OID 65423)
-- Dependencies: 211
-- Data for Name: sites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sites (id, created_at, updated_at, company_id, code, name, description, address, city, country, is_parent, is_active, parent_site_id) FROM stdin;
3bd17892-f003-4ba2-86ef-715413c324f2	2025-12-23 20:52:29.379432+05:30	2025-12-23 20:52:29.379432+05:30	eb75a65b-055f-4408-a58c-71d233443c17	VMC_MAIN	Villa Maintenance Main Site	Primary site for villa maintenance	\N	\N	\N	t	t	\N
\.


--
-- TOC entry 4396 (class 0 OID 65745)
-- Dependencies: 234
-- Data for Name: sla_configurations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sla_configurations (id, company_id, created_at, updated_at, name, description, priority, first_response_time_minutes, acknowledgement_time_minutes, resolution_time_minutes, escalation_level_1_minutes, escalation_level_2_minutes, escalation_level_3_minutes, apply_business_hours, business_start_time, business_end_time, working_days, exclude_holidays, is_active, created_by_id) FROM stdin;
\.


--
-- TOC entry 4374 (class 0 OID 65437)
-- Dependencies: 212
-- Data for Name: space_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.space_categories (id, created_at, updated_at, code, name, description, is_active) FROM stdin;
\.


--
-- TOC entry 4375 (class 0 OID 65451)
-- Dependencies: 213
-- Data for Name: spaces; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spaces (id, company_id, created_at, updated_at, code, name, site_id, space_category_id, description, is_active, "siteId", "spaceCategoryId") FROM stdin;
\.


--
-- TOC entry 4392 (class 0 OID 65675)
-- Dependencies: 230
-- Data for Name: team_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.team_members (id, company_id, created_at, updated_at, team_id, user_id, is_lead, joined_at) FROM stdin;
\.


--
-- TOC entry 4393 (class 0 OID 65689)
-- Dependencies: 231
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.teams (id, company_id, created_at, updated_at, name, description, department_id, lead_user_id, is_active, color_code) FROM stdin;
\.


--
-- TOC entry 4389 (class 0 OID 65632)
-- Dependencies: 227
-- Data for Name: ticket_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ticket_attachments (id, company_id, created_at, updated_at, ticket_id, uploaded_by_id, file_name, original_name, mime_type, file_size, storage_path, storage_url, attachment_type, attachment_context, description, checksum, is_deleted, deleted_at, comment_id, image_width, image_height, thumbnail_url) FROM stdin;
38ce49ec-5df8-4554-8d42-df147fbd5b88	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:38:36.371913	2025-12-26 15:38:36.371913	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	44142ebb-779d-4e83-b0a2-3db691e389ff	0885e24f-6adf-4587-aaae-d4d4b21ad363.png	Screenshot 2025-12-24 at 6.15.22â¯PM.png	image/png	74062	tickets/107b8dc1-166c-482e-b7cb-6cdbe56c9d8e/0885e24f-6adf-4587-aaae-d4d4b21ad363.png	/uploads/tickets/107b8dc1-166c-482e-b7cb-6cdbe56c9d8e/0885e24f-6adf-4587-aaae-d4d4b21ad363.png	IMAGE	TICKET_CREATION	\N	ff827ae4539373fd1c69af79a4ac6d79	f	\N	\N	\N	\N	\N
0fc48ff6-8691-4b5f-bf2b-e2dd9c8f4794	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:47:54.678948	2025-12-26 16:47:54.678948	05facf4d-61bf-4457-bdfd-fd17ce140971	d105993f-6f85-4144-ba14-dd361ae6df2e	a471f1d5-59f5-4ff2-add9-1f432098c39c.png	Screenshot 2025-12-24 at 6.15.22â¯PM.png	image/png	74062	tickets/05facf4d-61bf-4457-bdfd-fd17ce140971/a471f1d5-59f5-4ff2-add9-1f432098c39c.png	/uploads/tickets/05facf4d-61bf-4457-bdfd-fd17ce140971/a471f1d5-59f5-4ff2-add9-1f432098c39c.png	IMAGE	TICKET_CREATION	\N	ff827ae4539373fd1c69af79a4ac6d79	f	\N	\N	\N	\N	\N
2c68f69e-50b4-46e9-8da5-4454c2686132	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:18:13.287188	2025-12-26 17:18:13.287188	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	5f32aa47-7143-401a-97d4-9ad320c389b7.png	Screenshot 2025-12-24 at 6.15.22â¯PM.png	image/png	74062	tickets/443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b/5f32aa47-7143-401a-97d4-9ad320c389b7.png	/uploads/tickets/443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b/5f32aa47-7143-401a-97d4-9ad320c389b7.png	IMAGE	TICKET_CREATION	\N	ff827ae4539373fd1c69af79a4ac6d79	f	\N	\N	\N	\N	\N
0ce72f0f-7a26-4607-b8ca-e0a941f771bb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:46:18.490517	2025-12-26 17:46:18.490517	91f281b9-f724-4226-b12e-062f987dc6d8	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	159fedff-3a1f-44f5-9330-4af0091cdebb.png	Screenshot 2025-12-24 at 6.15.22â¯PM.png	image/png	74062	tickets/91f281b9-f724-4226-b12e-062f987dc6d8/159fedff-3a1f-44f5-9330-4af0091cdebb.png	/uploads/tickets/91f281b9-f724-4226-b12e-062f987dc6d8/159fedff-3a1f-44f5-9330-4af0091cdebb.png	IMAGE	TICKET_CREATION	\N	ff827ae4539373fd1c69af79a4ac6d79	f	\N	\N	\N	\N	\N
58dc1356-2ff2-44e7-a054-bb58148d2d99	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:17:54.114414	2025-12-26 18:17:54.114414	f22f9ddc-e255-4310-b37d-f607174bc053	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	d687cc68-71c2-499b-98dd-d2b3efc1f657.png	Screenshot 2025-12-24 at 6.15.22â¯PM.png	image/png	74062	tickets/f22f9ddc-e255-4310-b37d-f607174bc053/d687cc68-71c2-499b-98dd-d2b3efc1f657.png	/uploads/tickets/f22f9ddc-e255-4310-b37d-f607174bc053/d687cc68-71c2-499b-98dd-d2b3efc1f657.png	IMAGE	TICKET_CREATION	\N	ff827ae4539373fd1c69af79a4ac6d79	f	\N	\N	\N	\N	\N
37a709a1-e8d7-448e-ba58-dde390772649	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:49:15.054109	2025-12-30 12:49:15.054109	bd53d25e-e200-4720-9c48-b33871e16a95	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	8e3d1d30-44ad-4e40-b51f-c726ef211975.png	Screenshot 2025-12-29 at 2.06.39â¯PM.png	image/png	33369	tickets/bd53d25e-e200-4720-9c48-b33871e16a95/8e3d1d30-44ad-4e40-b51f-c726ef211975.png	/uploads/tickets/bd53d25e-e200-4720-9c48-b33871e16a95/8e3d1d30-44ad-4e40-b51f-c726ef211975.png	IMAGE	TICKET_CREATION	\N	388167384ce65d5cb1d0e55f52db32a5	f	\N	\N	\N	\N	\N
\.


--
-- TOC entry 4391 (class 0 OID 65660)
-- Dependencies: 229
-- Data for Name: ticket_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ticket_categories (id, company_id, created_at, updated_at, code, name, description, parent_category_id, display_order, is_active, icon, color_code, default_sla_hours, default_department_id, created_by_id) FROM stdin;
118c3e55-1621-46b3-9679-eb47407b1c75	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:26:08.971012	2025-12-23 15:26:08.971012	PLUMBING	Plumbing	Plumbing related issues	\N	1	t	\N	\N	\N	\N	\N
71733a01-e50a-4527-af54-463ea26b23e6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:26:08.980306	2025-12-23 15:26:08.980306	ELECTRICAL	Electrical	Electrical related issues	\N	2	t	\N	\N	\N	\N	\N
af8c4095-6700-48e9-83bc-58f4cbe7eb98	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:26:08.982194	2025-12-23 15:26:08.982194	HVAC	HVAC	Heating, ventilation, and air conditioning	\N	3	t	\N	\N	\N	\N	\N
ff3224ad-3a7d-4cc7-8e0c-55e9c0cac54d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:26:08.98326	2025-12-23 15:26:08.98326	CLEANING	Cleaning	Cleaning and maintenance requests	\N	4	t	\N	\N	\N	\N	\N
a8a2d41e-3f8b-4c93-bc32-141caade1b5f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:26:08.984411	2025-12-23 15:26:08.984411	SECURITY	Security	Security related issues	\N	5	t	\N	\N	\N	\N	\N
d3abf26d-6cf9-4b7f-bc0b-718a2f3413a2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:26:08.985635	2025-12-23 15:26:08.985635	GENERAL	General Maintenance	General maintenance and repairs	\N	6	t	\N	\N	\N	\N	\N
79f0dd48-1436-4432-a22b-81c7e36f9b33	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:26:08.986565	2025-12-23 15:26:08.986565	LANDSCAPING	Landscaping	Landscaping and outdoor maintenance	\N	7	t	\N	\N	\N	\N	\N
9f4a0f9c-6442-449c-a94e-c4e2467e7a47	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:09:24.218745	2025-12-24 12:09:24.218745	MISCELLANEOUS	Miscellaneous	Miscellaneous related issues	\N	8	t	\N	\N	\N	\N	95791439-c679-4dec-98cf-1eccedd65a87
\.


--
-- TOC entry 4388 (class 0 OID 65616)
-- Dependencies: 226
-- Data for Name: ticket_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ticket_comments (id, company_id, created_at, updated_at, ticket_id, created_by_id, content, comment_type, is_edited, edited_at, parent_comment_id, is_deleted, deleted_at) FROM stdin;
ef2ec466-1cec-42fd-9cda-2a58f964a6cf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:08:54.79502	2025-12-26 16:08:54.79502	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	44142ebb-779d-4e83-b0a2-3db691e389ff	testing	PUBLIC	f	\N	\N	f	\N
82d36775-24a4-4083-bc03-d886ca71d4fc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:09:08.436622	2025-12-26 16:09:08.436622	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	44142ebb-779d-4e83-b0a2-3db691e389ff	come at 9 to 10 in the front gate	PUBLIC	f	\N	\N	f	\N
387ed31a-9de6-4c45-b99a-2dbddb7235d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:09:36.089949	2025-12-26 16:09:36.089949	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Noted Sir	PUBLIC	f	\N	\N	f	\N
db86eb75-dbc4-4b01-b77d-c6a8f23b5fd6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:10:41.212142	2025-12-26 16:10:41.212142	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Agreed	PUBLIC	f	\N	\N	f	\N
0b0c4e8a-dbb9-4f89-9825-ba5e5ba99a4d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:48:20.075433	2025-12-26 16:48:20.075433	05facf4d-61bf-4457-bdfd-fd17ce140971	d105993f-6f85-4144-ba14-dd361ae6df2e	Come in the front gate	PUBLIC	f	\N	\N	f	\N
7096abae-cd15-466d-8c17-c827215ba803	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:49:16.623219	2025-12-26 16:49:16.623219	05facf4d-61bf-4457-bdfd-fd17ce140971	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Agreed	PUBLIC	f	\N	\N	f	\N
3e8a2506-6e1b-4898-9104-edb3da1d080e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:50:41.085702	2025-12-26 16:50:41.085702	05facf4d-61bf-4457-bdfd-fd17ce140971	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Okay	PUBLIC	f	\N	\N	f	\N
8ac235b2-b242-4b35-801d-a6ae953c8391	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:18:33.971843	2025-12-26 17:18:33.971843	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	use main left not the second one	PUBLIC	f	\N	\N	f	\N
c88d4156-3a9b-4cfe-8ec1-e63e1d80f052	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:19:16.511771	2025-12-26 17:19:16.511771	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Accpeted	PUBLIC	f	\N	\N	f	\N
54505e83-5077-41f6-a771-7cc98eaed2e1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:47:53.524568	2025-12-26 17:47:53.524568	91f281b9-f724-4226-b12e-062f987dc6d8	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Agreed working it	PUBLIC	f	\N	\N	f	\N
329321cb-1daa-4b2d-815c-58eda47ddc5a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:22:16.301895	2025-12-26 18:22:16.301895	f22f9ddc-e255-4310-b37d-f607174bc053	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Agreed	PUBLIC	f	\N	\N	f	\N
191fd99d-2e3a-42db-a8f2-383f21ae5ef3	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:29:16.739789	2026-01-01 08:29:16.739789	db1f2cb5-59c4-4e04-a340-ac894fc68772	95791439-c679-4dec-98cf-1eccedd65a87	test	PUBLIC	f	\N	\N	f	\N
40a2c295-d12b-4a85-992f-9095d2173340	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:21:38.454888	2026-01-01 09:21:38.454888	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	Testing	PUBLIC	f	\N	\N	f	\N
ce1fb411-8028-4fa2-98ce-a09ef63a9ed7	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:13.115493	2026-01-01 09:27:13.115493	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	test	PUBLIC	f	\N	\N	f	\N
254fe948-591f-49ed-90f6-7cdc03136b24	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:15.944618	2026-01-01 09:27:15.944618	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	Testtete	PUBLIC	f	\N	\N	f	\N
12122991-622c-4cce-bdb2-386905feb2d0	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:18.31595	2026-01-01 09:27:18.31595	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	tsateete	PUBLIC	f	\N	\N	f	\N
9c5f4463-3af1-41b5-a4e7-e3c06b4027ad	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:20.372804	2026-01-01 09:27:20.372804	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	testsete	PUBLIC	f	\N	\N	f	\N
9ab9e5d0-53dd-4093-b698-ecad55bdcc9d	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:24.243741	2026-01-01 09:27:24.243741	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	testset	PUBLIC	f	\N	\N	f	\N
107a1a50-abe1-4667-a061-a61c6c2e415d	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:26.51677	2026-01-01 09:27:26.51677	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	testetes	PUBLIC	f	\N	\N	f	\N
2684133a-b8ad-4d5d-960f-638244582a4a	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:28.616564	2026-01-01 09:27:28.616564	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	testsete	PUBLIC	f	\N	\N	f	\N
81ce5ad5-8974-4804-8de6-2038688f88cf	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 09:27:32.137455	2026-01-01 09:27:32.137455	518a030e-4357-4aaa-b019-03657ca5e722	44142ebb-779d-4e83-b0a2-3db691e389ff	testset	PUBLIC	f	\N	\N	f	\N
\.


--
-- TOC entry 4397 (class 0 OID 65760)
-- Dependencies: 235
-- Data for Name: ticket_sla; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ticket_sla (id, company_id, created_at, updated_at, ticket_id, sla_configuration_id, first_response_deadline, response_deadline, resolution_deadline, first_response_at, acknowledged_at, resolved_at, sla_status, first_response_breached, response_breached, resolution_breached, paused_at, total_paused_minutes, current_escalation_level, last_escalation_at, actual_response_minutes, actual_resolution_minutes) FROM stdin;
\.


--
-- TOC entry 4395 (class 0 OID 65733)
-- Dependencies: 233
-- Data for Name: ticket_status_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ticket_status_history (id, company_id, created_at, updated_at, ticket_id, previous_status, new_status, changed_by, notes, metadata) FROM stdin;
9e124a8b-6718-42da-8cde-26e088c8fc73	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3483f1de-1d2a-429f-af59-9b3cf4700680	\N	NEW	5e21829a-b5e3-4498-bb83-e912d258e2b8	\N	\N
af2c9596-e734-4677-85c4-621d40b5a1b9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fa7c3c70-4a2f-4251-91ea-22df5ffc7fcf	\N	NEW	42264350-62a4-4119-b213-4e2f68ebe513	\N	\N
d4d1aad9-9ca5-4e33-8169-370b14568630	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fa7c3c70-4a2f-4251-91ea-22df5ffc7fcf	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
fdeb3654-0662-40ff-b880-783dd9d59756	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fa7c3c70-4a2f-4251-91ea-22df5ffc7fcf	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
ee254013-4911-4cd8-8592-80b4bb82cebb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fa7c3c70-4a2f-4251-91ea-22df5ffc7fcf	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
6663bfba-d106-4ac1-b880-45fc9a4df375	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fa7c3c70-4a2f-4251-91ea-22df5ffc7fcf	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
bcd5e506-9d0b-4c98-8418-2b7ccd3f10e4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	82dd8690-aba5-4e40-9161-75f974115a2e	\N	NEW	2882fe7b-13dd-4184-94da-d8b80c2a06c7	\N	\N
8a869d14-7794-4a64-bfe4-1402b875499b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	82dd8690-aba5-4e40-9161-75f974115a2e	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
a69d9186-dc1f-4545-8738-895990dd496e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	82dd8690-aba5-4e40-9161-75f974115a2e	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
eb676014-6fae-492b-a72e-0bdf8a263d9a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3df03256-c410-4069-af89-929fea564c7f	\N	NEW	8bcb8775-4b58-4050-85f8-885a9b8b0fe4	\N	\N
d26dfd2a-1c9a-493b-a63c-8189113139ed	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a0385bc4-a031-4334-b680-fdd2e1beecde	\N	NEW	2c4ad4f5-3790-4cba-b383-bab4e583109f	\N	\N
addb3b99-02cd-4433-9d5c-11699bdc6aae	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a0385bc4-a031-4334-b680-fdd2e1beecde	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
9c5f9193-14f0-4cab-94a4-57aaa58bb202	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a0385bc4-a031-4334-b680-fdd2e1beecde	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
194339b1-ab82-4593-b016-3c452f39f6d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a0385bc4-a031-4334-b680-fdd2e1beecde	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
2b7f759d-c92b-4a3e-86be-07d18ac2b361	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	33cc2382-ded5-4bf5-a274-8c1bc8b6dd68	\N	NEW	2c4ad4f5-3790-4cba-b383-bab4e583109f	\N	\N
5f272175-908b-4bba-98ee-3e289ff0ffac	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d0b4be94-6851-4de4-84f5-d2225dd8b07f	\N	NEW	b18189ca-de52-4473-abc4-4e019eb74fef	\N	\N
a63627fe-90a5-439d-866b-6ef345a4702b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d0b4be94-6851-4de4-84f5-d2225dd8b07f	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b55af631-8db6-441a-97bf-c9252cc95c1c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d0b4be94-6851-4de4-84f5-d2225dd8b07f	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
a1241bdd-c5d2-4587-a0b6-0b0035e1952f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d0b4be94-6851-4de4-84f5-d2225dd8b07f	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
94b3c305-55e0-483b-bd78-f1b3260a4564	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d0b4be94-6851-4de4-84f5-d2225dd8b07f	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
7177f0cc-3fc5-4094-84c1-a29ff7d122da	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	6be7d5bb-37b1-422e-a11a-846b24dee100	\N	NEW	2c4ad4f5-3790-4cba-b383-bab4e583109f	\N	\N
e343ee5a-ea9d-4acd-a1c3-3130a988fcff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	6be7d5bb-37b1-422e-a11a-846b24dee100	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
08c375b4-6f7f-4325-abbb-c12e02d6e66b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0fe27475-1bbc-4a4a-9f0b-0ac758ec46e8	\N	NEW	0018a2fa-7431-421b-b0a6-6fdbd5878622	\N	\N
27809eb7-34ff-4942-a77a-8966d1756ffe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0fe27475-1bbc-4a4a-9f0b-0ac758ec46e8	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
6ea0a84b-1c35-49fe-9693-987e2276a5ef	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0fe27475-1bbc-4a4a-9f0b-0ac758ec46e8	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
2ecc6b5d-d245-4b87-8e56-6c64ab3f13cf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	18a7e380-6296-4cfa-9e7a-f557a11e43c3	\N	NEW	e59de9e0-b09d-40fd-9924-3aba2fb86d7b	\N	\N
d46f1796-1cf9-4ca6-b116-d223e94e0a7d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	18a7e380-6296-4cfa-9e7a-f557a11e43c3	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
012c9e11-8eda-4c3a-a10f-00670c7fa92b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9b9c9474-8ce9-4980-b564-44947ca428a5	\N	NEW	390bd96a-c854-416d-8660-802e754dfe30	\N	\N
40af4e77-0d7c-43d2-9924-d4168df57a22	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9b9c9474-8ce9-4980-b564-44947ca428a5	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
6255acda-cb24-40ee-9c7d-308ba18ffe48	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9b9c9474-8ce9-4980-b564-44947ca428a5	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
233b319d-9d0d-449f-8256-e8b42db12a8c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e693d5dd-7e78-429e-8fc5-9f6f01956cfe	\N	NEW	fd842408-0197-42b3-b459-d674809b1276	\N	\N
4c2bbb93-7b26-4c88-8921-ef2f0093630e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e693d5dd-7e78-429e-8fc5-9f6f01956cfe	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
29ba810f-4972-42ff-97b5-43a1dee03538	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e693d5dd-7e78-429e-8fc5-9f6f01956cfe	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
a70e66ba-7230-47ac-bb1d-aec2abadb8bf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5b4857ca-8af7-4b93-b9f7-0eb0fbfc1175	\N	NEW	0eb03419-5169-4605-a380-679a5d9faf95	\N	\N
9ff1ca8b-5d85-4710-a0dd-65f8d3f6973a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5b4857ca-8af7-4b93-b9f7-0eb0fbfc1175	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
6e3fed7e-c0d9-40c9-a644-5c725bbb4136	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5b4857ca-8af7-4b93-b9f7-0eb0fbfc1175	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
308e2a29-b8ad-4b28-a4a6-e3369ac78c3f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5b4857ca-8af7-4b93-b9f7-0eb0fbfc1175	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
5892ab4c-5175-4a98-97ef-f11ca22e53b8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5b4857ca-8af7-4b93-b9f7-0eb0fbfc1175	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
cb47d5ba-a839-4fe2-b9fa-7a8d9c0fbb9f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	70158969-a9f5-4346-bf1b-fb3259bbcb25	\N	NEW	b18189ca-de52-4473-abc4-4e019eb74fef	\N	\N
5d234f3a-7f98-4c48-b73a-03c42fc14c8d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	70158969-a9f5-4346-bf1b-fb3259bbcb25	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
d707f315-19e8-464c-aa68-5c8f1d7d117b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	70158969-a9f5-4346-bf1b-fb3259bbcb25	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
f0dabf33-4e25-4aca-b3df-3311172eaeff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	70158969-a9f5-4346-bf1b-fb3259bbcb25	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
5c45b368-182a-45db-83ca-e2119ceea20f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	70158969-a9f5-4346-bf1b-fb3259bbcb25	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
ba6e0eca-6845-4cac-b659-8b57666a7a86	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd6fc370-f9d6-4c77-9ce6-bceff8565c2d	\N	NEW	cffd4755-5598-42df-8634-68beb98c13a4	\N	\N
939d5078-b577-40ee-8211-9977b13e688b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd6fc370-f9d6-4c77-9ce6-bceff8565c2d	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
564b44aa-2264-48d3-8a13-96e53a90b5ac	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd6fc370-f9d6-4c77-9ce6-bceff8565c2d	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
eb481a1d-24d0-47f4-9fc6-234a0c3843d5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d740e963-adab-4bda-b64a-6a038243fa3a	\N	NEW	60803f2d-364d-4286-8fdc-8248485b9b82	\N	\N
4c9a96bf-d5f9-4de7-8a96-bd53ff6778d3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d740e963-adab-4bda-b64a-6a038243fa3a	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
e670f32a-1919-4fa1-a62e-bb7c9ad3679b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d740e963-adab-4bda-b64a-6a038243fa3a	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
982a8957-0a99-4250-9c78-0fe1e21dd54f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d740e963-adab-4bda-b64a-6a038243fa3a	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
27be9a16-87ef-4c48-802a-ea70bacf54e2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d740e963-adab-4bda-b64a-6a038243fa3a	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
bbf0a3fd-6b3d-4e02-b117-d01d6eb4fb77	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a6fbdc53-f6c7-42ba-be50-c1e146f3c9e2	\N	NEW	1d97134a-1b6a-47da-b3da-9324aa1a2f69	\N	\N
aad8f642-0b78-42dc-bd21-23b6f6db11f9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a6fbdc53-f6c7-42ba-be50-c1e146f3c9e2	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ae6ba436-1e51-4853-81f2-1f9e1a7257d0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a6fbdc53-f6c7-42ba-be50-c1e146f3c9e2	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
c219cd06-6eea-4fcd-9ee0-38f6c00622ab	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9928873f-639a-4a70-8c1a-fe39a8f5f4fd	\N	NEW	148547a8-d99f-4fb4-bb01-5bb7c6f2b159	\N	\N
a65e7aa7-4c60-4f67-9893-1170be2ca1e7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	38cf0d4d-b362-4578-941e-40973a06d818	\N	NEW	8eb63fe5-7d76-48a0-9456-36d698f469ed	\N	\N
8dc5d8d2-1138-443b-b966-483776975486	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	47247a33-d78a-4e82-99df-953e70160e5f	\N	NEW	407f8619-e786-4515-8bbe-1676e3bbc361	\N	\N
73f19f4f-a567-4773-a372-572d7e235907	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	38cf0d4d-b362-4578-941e-40973a06d818	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
2642bd06-21d0-4018-b819-117a97ad7972	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	38cf0d4d-b362-4578-941e-40973a06d818	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
5215b822-62a6-4241-94de-6d887fe164fb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	38cf0d4d-b362-4578-941e-40973a06d818	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
9d268b20-20d8-4c51-88dd-89032dd754ba	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0d3492db-db3b-49d0-a01d-fe447ae3136e	\N	NEW	c9bc0f9b-4414-4242-bb3f-ff992ef747e1	\N	\N
f4892b3d-e5da-42af-b31a-a75bad3bedce	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0d3492db-db3b-49d0-a01d-fe447ae3136e	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b4adc5f3-d7e7-4e9e-89d1-6d7e9bc17daf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0d3492db-db3b-49d0-a01d-fe447ae3136e	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
34f10e94-aeed-4ae7-ad3c-33ae7042d03e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0d3492db-db3b-49d0-a01d-fe447ae3136e	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
1d2bfbfc-9f35-427a-acaf-aebdd5a2a2d5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8c673c3-45df-45a8-85d1-99518bfa243a	\N	NEW	98c7399e-0621-457a-b93b-d8eeaaac4630	\N	\N
58517f85-24fd-4863-a254-a2d10c89b064	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8c673c3-45df-45a8-85d1-99518bfa243a	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
e527f16e-b2ec-4c83-8196-43002bde277a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8c673c3-45df-45a8-85d1-99518bfa243a	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
d4fad3f8-0935-4826-a40a-763297f94376	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8c673c3-45df-45a8-85d1-99518bfa243a	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
c26e84c2-1e8f-45ba-b3ca-b11b7083b022	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e7460bfc-e80c-4022-ab82-ecee90db98c9	\N	NEW	71e291b7-f092-40b6-9819-8fc848682e6a	\N	\N
ee58c3f5-be5c-4220-bc7a-fb6dbbe66d29	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e7460bfc-e80c-4022-ab82-ecee90db98c9	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b06b76da-3c78-47f1-8cbb-fc7204d93080	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e7460bfc-e80c-4022-ab82-ecee90db98c9	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
68d3f900-cc33-43d3-9995-a18dcc36c4fa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e7460bfc-e80c-4022-ab82-ecee90db98c9	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
d941c780-76f4-4502-ab0e-6fbb7ffcc436	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	dc3fab29-8aa4-48c5-b397-0e345f501293	\N	NEW	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	\N	\N
d36517ed-8d35-4f11-91eb-7c1ce5dea196	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	dc3fab29-8aa4-48c5-b397-0e345f501293	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
65a23ead-3b23-42a7-96a4-b1349b8dce95	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	dc3fab29-8aa4-48c5-b397-0e345f501293	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
35ba6c28-da1d-498e-b05d-cfed75ddc503	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	dc3fab29-8aa4-48c5-b397-0e345f501293	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
d68a5952-ef27-425d-b3f5-2fff73700c63	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	dc3fab29-8aa4-48c5-b397-0e345f501293	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
dafa837e-d056-4147-8cc4-73e775097148	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fbd21f2c-a3d4-4511-a9ee-315b4c01dc8c	\N	NEW	53bde808-7662-4bfc-a407-54fd1b83b4f6	\N	\N
6bcac562-f452-44a8-b134-0143d49b1e82	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fbd21f2c-a3d4-4511-a9ee-315b4c01dc8c	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
aa47fb48-4055-41e0-9edc-1ca800c3f9ff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d1e028f8-1539-4598-97a9-86e8b9c94c90	\N	NEW	ccdaf2d6-3905-4d04-b7a9-c6ac5c3ac2d0	\N	\N
a08551aa-4bee-4f68-8e41-c1f811edd250	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	eb1893f3-5cab-403c-a696-abd7bcdf6061	\N	NEW	398a1e8a-ff59-49d9-a52f-86d0270964ff	\N	\N
83ad538c-f96d-4643-82c0-1196a9350e2c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	56e49a79-aafa-410e-abf7-edc43c25558a	\N	NEW	c9bc0f9b-4414-4242-bb3f-ff992ef747e1	\N	\N
d8feeb52-920b-4cbe-84a7-72bebb624db4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	56e49a79-aafa-410e-abf7-edc43c25558a	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
3ba608ec-9730-4f57-bc33-1363ee02f248	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	56e49a79-aafa-410e-abf7-edc43c25558a	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
d393f3a9-38ac-46fc-aae9-aa9c03e31c88	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	56e49a79-aafa-410e-abf7-edc43c25558a	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
d626e005-c65d-4dec-9252-4d24b8a1d184	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc3c7dca-0075-4363-ae60-1893d1e9a33c	\N	NEW	4cb39fa4-be14-4a89-9fae-f88ea5406111	\N	\N
40b42ead-c44b-4623-a4b7-f7a325827aac	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc3c7dca-0075-4363-ae60-1893d1e9a33c	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
7c887377-66c0-49e3-9d0e-364b600292a8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc3c7dca-0075-4363-ae60-1893d1e9a33c	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
f59d7e1e-98b8-47cd-8476-b30a3c4ecccf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc3c7dca-0075-4363-ae60-1893d1e9a33c	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
3f57cc5f-a0c6-40c7-8ad0-f27eca67e5e6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc3c7dca-0075-4363-ae60-1893d1e9a33c	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
28fb98f8-95be-4f5f-9dae-44804e3bc812	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b25cb650-037f-46ea-8c28-538db34c3703	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	\N	\N
5c45f6bd-8105-4802-9371-631e7d43236d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b25cb650-037f-46ea-8c28-538db34c3703	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
c53b00e4-7193-4aed-9161-68f41d60148c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b25cb650-037f-46ea-8c28-538db34c3703	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
8142905f-ee2e-489b-b586-8ff7e8121350	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b25cb650-037f-46ea-8c28-538db34c3703	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
89d1c676-a94b-4826-ae42-981211ee72d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	46f7e756-b3b9-4124-9bf3-b885a2374483	\N	NEW	676ad3ae-87fa-4a38-8bf7-2debba141c77	\N	\N
d029ad76-abf5-4b1d-b687-e1ab0362f405	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d054d4d8-584c-4f2e-9fd8-bac4a5fbb2a2	\N	NEW	e59de9e0-b09d-40fd-9924-3aba2fb86d7b	\N	\N
5a9f0dc4-c322-42f9-a90c-de78e2c640e3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d054d4d8-584c-4f2e-9fd8-bac4a5fbb2a2	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
2d7f8bef-af02-4916-9302-859d4f41fffb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	229a7341-f132-4ad4-8819-0a05db1e4ad6	\N	NEW	e4072a3c-cca1-44cf-a465-dcf6281fbcd3	\N	\N
07e19918-e534-4c74-a188-2b77667dc9ba	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	229a7341-f132-4ad4-8819-0a05db1e4ad6	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
376a53de-aa1e-43c2-82a9-d83c05d16670	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	229a7341-f132-4ad4-8819-0a05db1e4ad6	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
2dab2a6a-fe48-400b-9a9e-97b60c153d81	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	229a7341-f132-4ad4-8819-0a05db1e4ad6	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
d62802cf-8e79-4792-9c45-533fd3378774	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8af4b35-197f-4240-93d7-a74545bda5fc	\N	NEW	b4968123-7908-457a-9e7c-2ae17c8fadaa	\N	\N
cfb254e6-2c40-49a8-9c2d-b5656c885864	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8af4b35-197f-4240-93d7-a74545bda5fc	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ddb87ca2-a710-4796-adb2-af8672b310c2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	dd9c787e-d752-4c50-af6f-0cc607af8ab6	\N	NEW	2c4ad4f5-3790-4cba-b383-bab4e583109f	\N	\N
172b0c6a-c3d5-4e0d-8092-3523649fa58b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	dd9c787e-d752-4c50-af6f-0cc607af8ab6	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
632cb4d1-e540-49bd-b997-ca033290ea7c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	49f97491-3f7e-4d96-928c-047dc634c252	\N	NEW	03b5e215-5057-405c-9ba4-a3485b1d0c89	\N	\N
0defa5a1-5dd1-4be5-8cb5-fcd5314c78b9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	49f97491-3f7e-4d96-928c-047dc634c252	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
dbfe6392-ff83-496b-ad11-2f180d226369	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	49f97491-3f7e-4d96-928c-047dc634c252	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
618d293d-1e64-4253-bce6-6f8cab66f362	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	49f97491-3f7e-4d96-928c-047dc634c252	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
7ef21f36-7d7c-4f2f-99af-9bfe4f8e4adb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	49f97491-3f7e-4d96-928c-047dc634c252	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
81236fb7-f717-455f-b823-5d7dd885ba5c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	58520a13-24ec-4870-bd55-01384a49de1f	\N	NEW	5e21829a-b5e3-4498-bb83-e912d258e2b8	\N	\N
f7edd31e-a471-4294-906a-9d1b3f268c47	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	50f91c3e-49e2-410a-920f-7302fe0d84cd	\N	NEW	71e291b7-f092-40b6-9819-8fc848682e6a	\N	\N
d628c1a6-f5f6-4c1c-9de7-db0d674f7ee6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	50f91c3e-49e2-410a-920f-7302fe0d84cd	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
453000e8-083f-4651-909c-3c2d53548f4b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	50f91c3e-49e2-410a-920f-7302fe0d84cd	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
abd81c49-4d6f-45cf-a861-746efe2a2d2a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	55ec17c2-5686-46ac-9240-d6b665ed9db6	\N	NEW	38d853ee-2655-4675-94c3-32aa7c6710e9	\N	\N
9948bc53-f1cf-4956-a0bb-c856b6b93861	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	55ec17c2-5686-46ac-9240-d6b665ed9db6	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
0dadbb4d-a157-4e18-b09e-1a60c3ccb59a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	55ec17c2-5686-46ac-9240-d6b665ed9db6	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
a88f9788-16c0-4305-94c3-85fa0e4cb62b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	55ec17c2-5686-46ac-9240-d6b665ed9db6	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
5d56f4b8-6951-47bf-9803-69a4a75947c2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	55ec17c2-5686-46ac-9240-d6b665ed9db6	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
41c3808b-deb5-49a1-abb6-7d3f94255964	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	24f292cd-f246-40c7-8327-15a6b344138d	\N	NEW	cffd4755-5598-42df-8634-68beb98c13a4	\N	\N
8935600c-bde5-4b0d-85d3-65c98e7aaf03	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	24f292cd-f246-40c7-8327-15a6b344138d	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
7eaf4fac-77ef-48b3-bb87-c8977219d90e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	24f292cd-f246-40c7-8327-15a6b344138d	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
ddf27f65-ad2f-4e38-8b6d-89bdbdcb9f2d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	24f292cd-f246-40c7-8327-15a6b344138d	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
58f485ff-5b75-488d-8eb0-051522f5c07d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	24f292cd-f246-40c7-8327-15a6b344138d	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
f423a937-1896-4024-99cb-439efb09ab6d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2ad0523c-cf89-419a-835b-212d99bb0cef	\N	NEW	1da9779d-0ee5-4a93-8e48-254e19ea71eb	\N	\N
62800d2a-1d3a-421a-b425-cfdd5962690b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2ad0523c-cf89-419a-835b-212d99bb0cef	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
d6933d97-928b-490a-91eb-82efd5b4b5f3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	29287320-4b90-4196-abae-3bec8e4a7236	\N	NEW	a20f0416-b723-4615-b9dd-644a7cee6f75	\N	\N
1e520de9-30ea-4e1d-bf2e-baccaea580f5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	29287320-4b90-4196-abae-3bec8e4a7236	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
8a88cd57-728d-4163-8895-daee0f4d92f5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	29287320-4b90-4196-abae-3bec8e4a7236	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
4305e6cc-02f9-4f28-b01f-d84f13f905c5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f09b9832-337a-4814-be81-625fea594863	\N	NEW	9fc4ca33-d77a-452f-aa97-677485aa2285	\N	\N
a1abae34-3531-4d37-ba89-b5eb229f06ce	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e6488155-09dd-4389-87a5-01ba3fd96ed9	\N	NEW	390bd96a-c854-416d-8660-802e754dfe30	\N	\N
ed2965fa-cc5e-4d28-b7da-dda8590b2fe3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e6488155-09dd-4389-87a5-01ba3fd96ed9	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
a10fe3d8-1ba0-4e89-964b-9f4cf47abce6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e6488155-09dd-4389-87a5-01ba3fd96ed9	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
6c4585e2-1d06-4db0-a55d-8993cde70fbb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e6488155-09dd-4389-87a5-01ba3fd96ed9	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
44a12668-9f84-490a-a42b-0cd538325a0f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d9d8a1e7-a9de-40dc-8ce4-e92dfa4efd6c	\N	NEW	71e291b7-f092-40b6-9819-8fc848682e6a	\N	\N
c223c9d8-7a1c-4c73-a51c-be1869e00fff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d9d8a1e7-a9de-40dc-8ce4-e92dfa4efd6c	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
f72c49dd-c659-46a9-a7a4-8a2430509ca5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d9d8a1e7-a9de-40dc-8ce4-e92dfa4efd6c	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
a396604e-9359-41ad-a3a3-57c32a92e688	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d9d8a1e7-a9de-40dc-8ce4-e92dfa4efd6c	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
30784b0d-d8eb-4a13-a92e-0744a885ded1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c426b74b-ff34-409f-9c41-4ad1e0150ec1	\N	NEW	93d899ce-d497-4f95-82b2-fe293db75dc5	\N	\N
647ad097-447d-44ed-812f-e01bb6e5e212	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c426b74b-ff34-409f-9c41-4ad1e0150ec1	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ed72ceaf-5faf-4a13-8768-a9f2cb958d1e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c426b74b-ff34-409f-9c41-4ad1e0150ec1	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
f800f8ac-d80f-4644-94b3-0133e0741096	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0b2fa8-24b3-4f3c-8e12-7462216ec8c4	\N	NEW	d66b699b-9605-4c11-9730-dcb26df0f882	\N	\N
6735d1b6-f701-496b-ac3b-7806d84b5b6d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0b2fa8-24b3-4f3c-8e12-7462216ec8c4	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
1fd4667d-3a2d-4d70-8c20-2c8ce2ceb550	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0b2fa8-24b3-4f3c-8e12-7462216ec8c4	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
b012a538-3ac6-4f36-bc02-3af0a0bac047	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0b2fa8-24b3-4f3c-8e12-7462216ec8c4	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
81c8a3af-6818-4b41-94e9-78253c06c2aa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0b2fa8-24b3-4f3c-8e12-7462216ec8c4	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
be967fe9-226e-43db-a8d5-856dee505d48	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	37015f24-5085-4c4e-b322-90a753484047	\N	NEW	d0836e66-8c5a-4a56-985e-c04f2bea6fc4	\N	\N
8e215519-66b8-46f7-821e-8eeb8746ee3a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	37015f24-5085-4c4e-b322-90a753484047	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
7fc393f3-7f32-430f-afde-043218077a75	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	37015f24-5085-4c4e-b322-90a753484047	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
7846f639-3814-4df7-83c7-7d90d31ab4f2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7f393ced-e1ba-4d5c-b13b-1f345c1edafb	\N	NEW	61e3614b-3b90-47a9-baf7-ecf8e7a6b96c	\N	\N
10e33bd4-1230-4105-a9db-8d649f32a893	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7f393ced-e1ba-4d5c-b13b-1f345c1edafb	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
3b04abc2-0ba4-484e-b866-719e89c21af8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7f393ced-e1ba-4d5c-b13b-1f345c1edafb	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
bd4ec2fb-43bc-473a-b434-a96648fe5ba6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ddb67e47-6372-4951-8456-cc6405d01753	\N	NEW	61e3614b-3b90-47a9-baf7-ecf8e7a6b96c	\N	\N
79e69d3c-0573-4990-9d7e-8c9898424829	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ddb67e47-6372-4951-8456-cc6405d01753	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
85ab7b9d-9012-4222-9117-830ff74c7263	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ddb67e47-6372-4951-8456-cc6405d01753	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
05ded9a9-6dc4-49cc-a08a-7ed05cfae1f9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d767bd60-db09-45ee-adc4-817379fb527e	\N	NEW	b18189ca-de52-4473-abc4-4e019eb74fef	\N	\N
671acfa6-4380-45a2-8eb4-73199fbd72a2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d767bd60-db09-45ee-adc4-817379fb527e	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b83fddd6-394e-4958-9dae-cbb38f033665	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d767bd60-db09-45ee-adc4-817379fb527e	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
5ce736e3-538a-48fe-a58d-d5ebebc2ea32	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d767bd60-db09-45ee-adc4-817379fb527e	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
2df36be7-971d-4aab-9e93-cac70c2fcc06	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c6fd1853-c133-4b7a-8117-5a4e78d56807	\N	NEW	457cc731-4a14-462c-bba5-c0a67fe2b0e4	\N	\N
3ce67e1c-625e-450a-86d9-743946393d0d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c6fd1853-c133-4b7a-8117-5a4e78d56807	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
4afe81b3-9d07-468a-a8bd-d6775fb06c26	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c6fd1853-c133-4b7a-8117-5a4e78d56807	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
53d73756-8daf-46cf-8707-cbf22d28b316	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c6fd1853-c133-4b7a-8117-5a4e78d56807	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
a7875cd1-c35d-481d-9d8b-ecbc2e097c1d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4507aa38-8187-42c3-a91e-aca1d2dc88fc	\N	NEW	2df7ef09-1682-43c9-9c64-e479c86c1c1e	\N	\N
57d12f13-195b-44b5-a45d-5515af00ea5b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4507aa38-8187-42c3-a91e-aca1d2dc88fc	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
119ddbb6-f0ba-451d-887e-b7cd3166ffa3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f181e42a-b99a-41bf-872e-8623f0e9049b	\N	NEW	0018a2fa-7431-421b-b0a6-6fdbd5878622	\N	\N
dfcf6053-4275-4b91-8f70-3e792f1bd2bb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4f3dbf54-5988-46b5-954b-c30630926fc3	\N	NEW	5b91137f-8c0a-403f-8bd3-f26ba765e8a3	\N	\N
abcd9ebc-f3dd-4bbf-9566-c20452d9a762	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4f3dbf54-5988-46b5-954b-c30630926fc3	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
50a986ca-45fe-45f2-850c-4a939e3650c6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4f3dbf54-5988-46b5-954b-c30630926fc3	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
37614acb-e949-45a7-9651-642771ff9195	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4f3dbf54-5988-46b5-954b-c30630926fc3	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
055c833a-b690-4daf-bca5-7c6e9d093dac	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4f3dbf54-5988-46b5-954b-c30630926fc3	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
5630bfb2-0fa0-460b-baaa-31830620363d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	312117bb-d37b-4740-93ed-2d9387571c97	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	\N	\N
3377f2a3-7f76-467d-993b-daac37c3e2c9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	312117bb-d37b-4740-93ed-2d9387571c97	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
6d8b83fb-4793-4142-84e5-e8b090b5d2a2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	312117bb-d37b-4740-93ed-2d9387571c97	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
7b76a9de-6314-48ed-a365-77f95c666f83	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e8ba105f-481f-4d03-8907-a74a76275de6	\N	NEW	0018a2fa-7431-421b-b0a6-6fdbd5878622	\N	\N
19e8feba-4d2e-4524-980c-f6c4ca3a7f42	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e8ba105f-481f-4d03-8907-a74a76275de6	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
35d73b92-6f4a-4f4e-969a-32849ad0f94e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e8ba105f-481f-4d03-8907-a74a76275de6	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
a50800e8-0ee8-4d32-a703-ed8f576bf9b9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e8ba105f-481f-4d03-8907-a74a76275de6	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
9c0ccc06-c24e-471b-b4de-e075c781fb9a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8ad4aec-82b2-4bc4-8010-b66763e3f1c8	\N	NEW	ec44affc-f5ff-40ef-a3de-b8f303fee488	\N	\N
81801376-e87b-4d1f-b2a0-b997d7372b3a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8ad4aec-82b2-4bc4-8010-b66763e3f1c8	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ca9baca5-1fdf-45c4-8ad1-d4e81a1b33e3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8ad4aec-82b2-4bc4-8010-b66763e3f1c8	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
710593d7-8759-4df7-a421-c28500ef9189	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8ad4aec-82b2-4bc4-8010-b66763e3f1c8	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
f3107d8d-efb3-4a41-a569-e74792bf66db	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c8ad4aec-82b2-4bc4-8010-b66763e3f1c8	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
6fa77423-0124-482a-9b2c-aa9cf90d87d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bb83d4b5-2fea-4677-9dbd-b53566cb9710	\N	NEW	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	\N	\N
21cc1472-f606-4791-9964-57ce970d5a2b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bb83d4b5-2fea-4677-9dbd-b53566cb9710	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
136e459c-97ef-43b6-ae8f-1e1c0c0a591d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bb83d4b5-2fea-4677-9dbd-b53566cb9710	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
65acd2fd-e69f-4977-abde-c138e3443fff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bb83d4b5-2fea-4677-9dbd-b53566cb9710	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
8542633e-a5f2-4bf2-8ffc-312e1281dc40	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bb83d4b5-2fea-4677-9dbd-b53566cb9710	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
598ba083-0e06-4430-ae9d-a308fb15c12d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d270cb85-b3fe-4247-8b06-942f9ad4659c	\N	NEW	398a1e8a-ff59-49d9-a52f-86d0270964ff	\N	\N
cbb13dd4-62c6-431a-9fb0-066402d4bb2c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d270cb85-b3fe-4247-8b06-942f9ad4659c	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
befc5bbe-a63d-4d69-a5bc-5161e2d557f4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d270cb85-b3fe-4247-8b06-942f9ad4659c	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
5a32a6be-d30a-4102-a497-83ac8174ff7c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d270cb85-b3fe-4247-8b06-942f9ad4659c	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
1fc8fe3d-5fcb-4141-ad33-42130a6c9c46	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d270cb85-b3fe-4247-8b06-942f9ad4659c	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
03081bc9-1c9f-4e6a-ad41-d63b5952350d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a3c2d4b5-703d-4f03-ac90-bda69671c748	\N	NEW	0018a2fa-7431-421b-b0a6-6fdbd5878622	\N	\N
b1db0012-1983-427c-bbb1-35b198c5e4b0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a3c2d4b5-703d-4f03-ac90-bda69671c748	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
9b8d2848-713d-4c81-963c-e8b0004357bc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a3c2d4b5-703d-4f03-ac90-bda69671c748	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
33ef48b5-487b-45fc-8a41-1205124ea024	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b08e1d18-12b3-40e5-b109-3b64a853685c	\N	NEW	4cb39fa4-be14-4a89-9fae-f88ea5406111	\N	\N
bf1e21cb-ce99-44bb-88cc-fd7f2f940a5f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b08e1d18-12b3-40e5-b109-3b64a853685c	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
79702d11-2ddf-4ca2-ae35-d76ea11a37a9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b08e1d18-12b3-40e5-b109-3b64a853685c	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
c1bdce85-723d-4b6f-925b-ccdf2e1258cc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	59f8f6f4-fb27-40d3-a30c-bce98a0fd81b	\N	NEW	61b1fbb4-305b-406d-8906-b48d47be9faf	\N	\N
9026c43d-d78b-4e6f-9e35-6533f0ac2810	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	59f8f6f4-fb27-40d3-a30c-bce98a0fd81b	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
0c8501b3-8334-4a03-a16e-22e83e6e952f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	59f8f6f4-fb27-40d3-a30c-bce98a0fd81b	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
5ae39ae3-7e74-464f-a41c-ecb50c959432	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	59f8f6f4-fb27-40d3-a30c-bce98a0fd81b	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
fc21615e-e2c0-4067-8bb6-b368c19fb58e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	59f8f6f4-fb27-40d3-a30c-bce98a0fd81b	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
94b90e23-91ba-469d-a521-8daea3a883a6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f5139e23-db44-449e-807b-2627b76c5a0f	\N	NEW	9bd4b184-458f-4eab-9472-6578042407e0	\N	\N
8fcd52e2-3cdc-47ab-a67a-189be101fb30	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f5139e23-db44-449e-807b-2627b76c5a0f	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
daa537e1-6aaf-46e3-8fae-e3b1f0699531	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f5139e23-db44-449e-807b-2627b76c5a0f	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
a23fad58-efbb-41cc-a311-9e64f7a4a170	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f5139e23-db44-449e-807b-2627b76c5a0f	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
b26fdaff-8a3a-494c-b9a0-700fda64c152	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0117f270-44ac-4b30-974a-7b099780466d	\N	NEW	cfb8af0f-11c6-464b-8e84-747f9cbdcb84	\N	\N
e9a4eb63-cc97-4f52-b1d3-f110252742fb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0117f270-44ac-4b30-974a-7b099780466d	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
1d00ef49-3420-4d9e-b61f-44d80f270684	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0117f270-44ac-4b30-974a-7b099780466d	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
8593aef8-98b2-4f68-a65e-1113f157c835	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0117f270-44ac-4b30-974a-7b099780466d	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
5baef43d-1822-4823-90da-96058ff124b6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0117f270-44ac-4b30-974a-7b099780466d	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
eb3b4c58-55f8-4776-9368-46b8caa4603a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	49f1e87c-6599-44c1-aa4d-d46c1598ef88	\N	NEW	aa1a0cdc-8202-4654-a28e-9bda086a3f84	\N	\N
42d0ec10-c8ae-4dac-b758-e7e791758ded	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	49f1e87c-6599-44c1-aa4d-d46c1598ef88	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
cd2eee7e-8b32-45db-89e9-bbecb3316982	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0d7aac42-22fa-4ea6-91c2-dfc653c21d4d	\N	NEW	53e744ac-828b-41ed-b12a-34f7829c1e38	\N	\N
fa3c3ffe-8dbb-47db-846b-448c0334ac59	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0d7aac42-22fa-4ea6-91c2-dfc653c21d4d	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
93dff19c-7463-49f1-a654-0a2ea944e916	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0d7aac42-22fa-4ea6-91c2-dfc653c21d4d	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
6862946c-393b-41c9-ba17-7b7065332c34	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0d7aac42-22fa-4ea6-91c2-dfc653c21d4d	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
59154263-9842-478c-8214-f6acfab9b6fb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	06ffe742-cd5e-489e-bf00-368c6685e497	\N	NEW	fd842408-0197-42b3-b459-d674809b1276	\N	\N
e0599557-56e5-44bc-883b-62cebed5920d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd2db933-ec7c-4fdd-b6de-b87576e84947	\N	NEW	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	\N	\N
dbfdb570-4ce0-4c01-8549-abbd60e7a33e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd2db933-ec7c-4fdd-b6de-b87576e84947	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
789adf95-4b8c-413c-ae63-48eccdbe6dae	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd2db933-ec7c-4fdd-b6de-b87576e84947	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
b4789d50-1ddb-48bb-9d29-d458500722c8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd2db933-ec7c-4fdd-b6de-b87576e84947	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
367eba77-bec9-40bb-be39-17305d79f106	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd2db933-ec7c-4fdd-b6de-b87576e84947	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
ae7c2561-4ed9-4a82-a50d-588fb25b05ba	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fdba8078-0a22-4a34-8966-bd8240b9673a	\N	NEW	42264350-62a4-4119-b213-4e2f68ebe513	\N	\N
f14fb253-1646-4885-b8fc-bc11ba6fbd76	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	48c598a0-566d-4c2a-9fd9-4bcb571543dd	\N	NEW	3a55a2a5-5792-4cac-8d1a-f89f2636b489	\N	\N
28d3964b-2e62-4fb4-8569-a4ae72f90d92	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	48c598a0-566d-4c2a-9fd9-4bcb571543dd	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
4c8e3c36-16e1-4731-a67a-6a74cbe412d2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	48c598a0-566d-4c2a-9fd9-4bcb571543dd	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
7b276ad2-1c48-4dd9-bea7-7b2436296877	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	48c598a0-566d-4c2a-9fd9-4bcb571543dd	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
f80481df-9f4a-4778-8f44-e5b66b9c79f0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	48c598a0-566d-4c2a-9fd9-4bcb571543dd	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
aeff7813-ea79-4fa2-9f23-376ec16c0c40	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	27f6481f-b86d-4f5d-aa65-906dbc075588	\N	NEW	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	\N	\N
f67050c2-6650-4ae0-98e8-22de22d7030a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ae436ed6-8123-45e2-9cbd-e4be8b07a5c0	\N	NEW	676ad3ae-87fa-4a38-8bf7-2debba141c77	\N	\N
9d51d6d3-0c5b-4128-bd44-c9b5efb7517a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ae436ed6-8123-45e2-9cbd-e4be8b07a5c0	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
121407cd-86d4-41a3-8f08-0245c78017e2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ae436ed6-8123-45e2-9cbd-e4be8b07a5c0	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
0e33ec17-6c9c-4628-af6d-0b3885ea3519	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ac53749f-d494-49de-9b6a-1282b00b3776	\N	NEW	9392dfcd-3eb4-428d-ab2f-fa38c0a33c90	\N	\N
5d7ca990-877f-4dba-97d2-804a1e5ca8e2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ac53749f-d494-49de-9b6a-1282b00b3776	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
a73ecc4b-4098-49e8-8581-e04e18cec7d9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ac53749f-d494-49de-9b6a-1282b00b3776	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
51abc711-6141-4a8a-92a6-a62d1a809bd4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ac53749f-d494-49de-9b6a-1282b00b3776	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
d373569c-5196-474f-9408-1da4948e3b08	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ac53749f-d494-49de-9b6a-1282b00b3776	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
81f99772-7653-4d8a-83f1-94d0a4745165	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9f98c423-a32d-4175-8275-a48cf0f6c070	\N	NEW	071618e8-48df-4397-bf58-13500b13b963	\N	\N
9a95320c-1120-42d6-bb73-381071ff7752	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9f98c423-a32d-4175-8275-a48cf0f6c070	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ed587f01-3286-4b41-9110-3a46b057ba7a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9f98c423-a32d-4175-8275-a48cf0f6c070	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
9987eb51-545e-4957-a98f-7214c6792e5d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9f98c423-a32d-4175-8275-a48cf0f6c070	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
7e8a2637-b296-4473-8245-b54f7bfefb94	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9f98c423-a32d-4175-8275-a48cf0f6c070	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
2f53a5ad-8e58-4fef-854e-3c02745717f9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c08ceec9-2909-4e7c-adf2-3087bf77c4a2	\N	NEW	470d6e78-cc9b-40a2-b365-25f7b3bba977	\N	\N
58166269-397d-4ccf-9b2d-60363afff9f4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c08ceec9-2909-4e7c-adf2-3087bf77c4a2	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
89a542fa-c7e1-46e4-8c17-b1caab99c593	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c08ceec9-2909-4e7c-adf2-3087bf77c4a2	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
87739936-c416-4911-be0d-1cef1ccbcd06	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c08ceec9-2909-4e7c-adf2-3087bf77c4a2	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
e8797843-a2d4-495d-878a-a93fd31f4ca5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c08ceec9-2909-4e7c-adf2-3087bf77c4a2	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
39e930d1-534d-4f31-807e-fb7a6212891a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d1f05648-e3a1-4084-9cd1-f429391ef5dd	\N	NEW	53bde808-7662-4bfc-a407-54fd1b83b4f6	\N	\N
d9e134e5-6a87-4aa8-89c9-8fcf79ca6f51	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d1f05648-e3a1-4084-9cd1-f429391ef5dd	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b37794b0-780a-4040-ab57-156b1e2a03d6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d1f05648-e3a1-4084-9cd1-f429391ef5dd	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
45dbc5d3-0076-4a8a-bd54-7328351ee9cc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d1f05648-e3a1-4084-9cd1-f429391ef5dd	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
e33b4557-def4-4117-bbe5-ed8519513eea	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d1f05648-e3a1-4084-9cd1-f429391ef5dd	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
6699cc07-ec30-40ce-9cd3-0146238ac3f8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ae0de313-ab6b-48ca-a4bb-df3805f5b5be	\N	NEW	d4c313e9-9190-43d3-9280-4e19a3619f44	\N	\N
971bc6e1-870e-4723-9148-aac26bbebd78	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ae0de313-ab6b-48ca-a4bb-df3805f5b5be	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b91c1c5b-113e-439b-9d58-5339ebbe5389	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ae0de313-ab6b-48ca-a4bb-df3805f5b5be	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
6ad48f98-5ddd-4b51-a23b-7a825cc05037	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a940e004-f238-4caa-808c-2067a949c0c7	\N	NEW	bb9480ff-bee6-48a3-bd70-a927f8faa96e	\N	\N
43427faf-a4ff-4ab9-bd52-3b3c29b401f9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a940e004-f238-4caa-808c-2067a949c0c7	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
88d46955-22eb-4408-801d-5e59b4dcee92	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a940e004-f238-4caa-808c-2067a949c0c7	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
d023b6d6-5ef8-4748-99df-a8dbd72ee5d7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a940e004-f238-4caa-808c-2067a949c0c7	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
7309911d-43db-4dbc-88d9-8bbc2ed408de	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0e8a466e-b8f4-420a-8979-827b3e5472d4	\N	NEW	457cc731-4a14-462c-bba5-c0a67fe2b0e4	\N	\N
b4954a3f-8fbd-47ba-85e5-5e9eddcda785	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0e8a466e-b8f4-420a-8979-827b3e5472d4	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
5d79bbb2-a4be-4ad4-8ac3-903ae65beb12	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0e8a466e-b8f4-420a-8979-827b3e5472d4	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
c5f7412d-28cd-45c9-a459-1a31a07d8f56	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0e8a466e-b8f4-420a-8979-827b3e5472d4	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
ef4542ed-4344-4630-90da-e74e16f58a13	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0e8a466e-b8f4-420a-8979-827b3e5472d4	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
1e0b060d-7c83-4d5c-a7dd-473b00baccbe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e9f0c22d-00a7-4a46-98ae-410638a954a4	\N	NEW	bb9480ff-bee6-48a3-bd70-a927f8faa96e	\N	\N
33e74ee0-36ae-4a0c-9e95-a5378b7e9545	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e9f0c22d-00a7-4a46-98ae-410638a954a4	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
9a7836cb-6756-4667-973f-ef737d124a5f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e9f0c22d-00a7-4a46-98ae-410638a954a4	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
a4c771d5-d1a0-425a-96cd-5262188385cb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e9f0c22d-00a7-4a46-98ae-410638a954a4	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
49d60049-9b4a-45e0-b9ab-7f49eaa56c69	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e9f0c22d-00a7-4a46-98ae-410638a954a4	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
df1e9f9e-c64b-4ff7-bccf-f69090264543	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7759c876-cd74-4f8d-b62c-b33b90c16dcc	\N	NEW	53bde808-7662-4bfc-a407-54fd1b83b4f6	\N	\N
e7d8ead4-7793-4727-a293-6c43e48b240e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7759c876-cd74-4f8d-b62c-b33b90c16dcc	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
5f5c9f59-c21b-4b63-86ae-69764c0bbfa6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7759c876-cd74-4f8d-b62c-b33b90c16dcc	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
1c38c6e4-a99d-4834-815b-096e37f0a0ad	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7759c876-cd74-4f8d-b62c-b33b90c16dcc	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
0d1b62ef-7099-4ee7-bc42-1c080982b7b0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7759c876-cd74-4f8d-b62c-b33b90c16dcc	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
6d83a377-f075-4b7d-98bb-a31c83879824	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f59922f9-dc91-4d25-81a4-e06b5834c319	\N	NEW	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	\N	\N
321e2bb1-13cc-4db4-9b69-db5e32a55a66	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f59922f9-dc91-4d25-81a4-e06b5834c319	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
aae8018f-3dc7-4dae-8d2d-3704e85ab6e5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f59922f9-dc91-4d25-81a4-e06b5834c319	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
83812742-215a-4f74-8a41-4d959115afbe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f59922f9-dc91-4d25-81a4-e06b5834c319	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
96b4f380-cd53-4e74-81d2-d0dae80bac25	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f59922f9-dc91-4d25-81a4-e06b5834c319	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
524910fa-91c1-4e89-89cd-b3072c73c928	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3b5253c9-3336-414e-b33a-708d6efe2627	\N	NEW	bb9480ff-bee6-48a3-bd70-a927f8faa96e	\N	\N
c70a5098-10e6-44f6-85cb-0d08d384571b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3b5253c9-3336-414e-b33a-708d6efe2627	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
273cfe49-dd00-4873-ab26-a68d656052b6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3b5253c9-3336-414e-b33a-708d6efe2627	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
3a1a1de4-d8d4-4074-8961-53365845550e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3b5253c9-3336-414e-b33a-708d6efe2627	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
4df09b2c-9888-4f3d-8474-d66c632c83df	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	17011426-113f-4c9e-9e39-2af737bf3e78	\N	NEW	f4c87468-fa82-45fc-aa90-d3668f808a3b	\N	\N
c49d06c7-af7b-457d-a9f4-1db6a9917552	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	17011426-113f-4c9e-9e39-2af737bf3e78	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
fbc19ccc-9912-4320-87b5-fc26985ffff5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	17011426-113f-4c9e-9e39-2af737bf3e78	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
94a1e132-17b1-4b7c-a548-89899c51589c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	17011426-113f-4c9e-9e39-2af737bf3e78	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
6bc339f8-1c26-4244-9944-2110eaee8a59	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	17011426-113f-4c9e-9e39-2af737bf3e78	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
ae52be47-8dcf-4ace-99de-caa1848f12db	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5ce985d3-b498-416d-8d4f-a0f52bb604ae	\N	NEW	4fd836c0-e4b7-4de5-ae7d-57a9d29b7325	\N	\N
f698204f-ea33-45aa-9472-bff57011878b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5ce985d3-b498-416d-8d4f-a0f52bb604ae	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b93b5399-972a-43ca-b587-56bc7e7f3a56	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5ce985d3-b498-416d-8d4f-a0f52bb604ae	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
9914d5c2-5bf4-45aa-a51e-571ef4352dbe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5ce985d3-b498-416d-8d4f-a0f52bb604ae	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
80ee2a83-1063-483e-b12f-e7557207f665	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5ce985d3-b498-416d-8d4f-a0f52bb604ae	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
e222e997-f3b0-4385-aa9b-0dede018590b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ecae75ba-5e2e-4879-995f-ace34b448749	\N	NEW	be7c2045-9191-4083-86c2-383c166520bc	\N	\N
99b7e164-1e49-4369-90de-1628b0a21074	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ecae75ba-5e2e-4879-995f-ace34b448749	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
2df110ab-3dba-4040-9657-13ce06d15d55	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ecae75ba-5e2e-4879-995f-ace34b448749	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
dee2021b-c33e-4c8a-bffa-932cc8297d57	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ecae75ba-5e2e-4879-995f-ace34b448749	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
8e9cd042-45db-4aa9-90c4-52088699302f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ecae75ba-5e2e-4879-995f-ace34b448749	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
eff26551-5be6-4bbb-84f9-94a8c9121751	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	978a5c77-b661-4721-9ddd-4905119082cc	\N	NEW	38a4ff0d-a3ad-4c48-b4e1-02706892b17d	\N	\N
62308247-8b91-41d9-aac7-0dbd51cb2c8b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	978a5c77-b661-4721-9ddd-4905119082cc	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
c190a0dd-9a74-4a1a-b55f-20f7ba81344d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	978a5c77-b661-4721-9ddd-4905119082cc	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
15f08dd9-73a5-47fa-a91b-45d01027b763	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	978a5c77-b661-4721-9ddd-4905119082cc	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
51c8cab9-f2d4-47f3-a571-59c6e08aa80b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	978a5c77-b661-4721-9ddd-4905119082cc	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
5fa87290-c97e-40f7-9d04-2152aab4f4c6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b830f3f9-6e16-4e24-baac-ea62cd733d08	\N	NEW	8eb63fe5-7d76-48a0-9456-36d698f469ed	\N	\N
cd925a68-04a2-45d1-a0cc-90c9bcba9856	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b830f3f9-6e16-4e24-baac-ea62cd733d08	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
8527ad4c-c6ae-4d77-a058-73b1adcde852	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b830f3f9-6e16-4e24-baac-ea62cd733d08	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
444b4493-e777-477c-ae09-b8d1bcd7d934	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b830f3f9-6e16-4e24-baac-ea62cd733d08	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
649d33d9-185b-414e-8901-9721b2c14ed7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	41f32279-440e-4414-b1e3-f4831973516e	\N	NEW	470d6e78-cc9b-40a2-b365-25f7b3bba977	\N	\N
02d4114e-fa3e-4e6a-b03e-e76d98aa4888	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	87fee608-a356-4d57-943b-afe2cb2b8d0b	\N	NEW	61b1fbb4-305b-406d-8906-b48d47be9faf	\N	\N
d4b0549d-d699-444f-a86c-45133757133f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	87fee608-a356-4d57-943b-afe2cb2b8d0b	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
13d6a7e9-6557-4865-842a-dbe3fa2dc9ae	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	87fee608-a356-4d57-943b-afe2cb2b8d0b	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
8d4c3f93-475b-4e50-b220-69523709b895	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	87fee608-a356-4d57-943b-afe2cb2b8d0b	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
f25d25c9-c2a0-46c5-8a01-cf05b06ea6d1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	44566b99-cd8a-48b7-b0fd-8304ef3a8046	\N	NEW	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	\N	\N
908aec82-b4e8-4e36-8cf6-a549e8534ba2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9c95e8a2-2cf2-488a-837a-ed24beddd397	\N	NEW	0018a2fa-7431-421b-b0a6-6fdbd5878622	\N	\N
b225b584-1c2a-426f-a776-feea96145f0e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9c95e8a2-2cf2-488a-837a-ed24beddd397	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
2b8a4ae5-8aeb-4863-9745-4b5e0c461d83	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9c95e8a2-2cf2-488a-837a-ed24beddd397	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
418723c3-3b4d-497d-8d28-473bfd6fbb85	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9c95e8a2-2cf2-488a-837a-ed24beddd397	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
c540342a-d6d8-4a5b-bcc6-05cb0b1b5dfe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9c95e8a2-2cf2-488a-837a-ed24beddd397	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
0a8218de-c03d-4030-a57a-34f243579378	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4f289ac7-d253-4083-a0f4-8be1986facb0	\N	NEW	d9361d85-2226-44be-b864-ad171091950c	\N	\N
fed4edd7-21f4-4020-ab49-d50bd273af7d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4f289ac7-d253-4083-a0f4-8be1986facb0	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
81bcd12a-2e28-4661-839e-d95bc9794e87	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4f289ac7-d253-4083-a0f4-8be1986facb0	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
91792c93-b60c-4ee4-be0a-0644395a7e9c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f09491ee-c2ad-4bf4-98a2-e36971a04b3a	\N	NEW	b1469661-e285-4513-ac3d-fffcc131daa6	\N	\N
f09754bb-3110-43a8-b1a2-138db28b1dbd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	91abeae8-30fb-45db-bb02-422520cbe6ba	\N	NEW	2c4ad4f5-3790-4cba-b383-bab4e583109f	\N	\N
a984c284-e58b-49c6-9fc5-cdfd076f4a7c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	91abeae8-30fb-45db-bb02-422520cbe6ba	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
f28dc10f-c190-4dca-b527-8f1145a642ff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	91abeae8-30fb-45db-bb02-422520cbe6ba	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
4b23fadf-467a-47bc-8432-4856338d7dc7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	91abeae8-30fb-45db-bb02-422520cbe6ba	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
46e5deb4-c69d-45f6-b197-7d28eb43aff9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8f74b68c-01f2-45ae-a411-0bc9ed3d11dc	\N	NEW	9826254b-4208-479f-af75-c59a0d88babb	\N	\N
e7dd5f75-5319-4105-b637-ab204fe7d795	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8f74b68c-01f2-45ae-a411-0bc9ed3d11dc	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
67ecd547-7923-406b-9d07-331570b11328	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8f74b68c-01f2-45ae-a411-0bc9ed3d11dc	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
3cbc2848-df8c-46e4-9b38-8268f6bde36d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8f74b68c-01f2-45ae-a411-0bc9ed3d11dc	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
362a7777-60d1-40b3-a76b-260fa83ac6a2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8f74b68c-01f2-45ae-a411-0bc9ed3d11dc	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
9acacd63-cb1f-443f-814f-5db615e45754	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1fe8419d-7be4-4961-a020-eb68b96fc436	\N	NEW	5ae848af-e1e2-4dc3-a14d-c8a5396b824e	\N	\N
6ace9dde-6391-427f-b06b-93fcb343ec65	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1fe8419d-7be4-4961-a020-eb68b96fc436	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
685a1daf-ed00-4249-bda6-2069469ce8f2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	6ea8a7d7-ac8e-4147-9c02-61d261915473	\N	NEW	9826254b-4208-479f-af75-c59a0d88babb	\N	\N
be037a40-e488-4298-9f00-af62628424c1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	6ea8a7d7-ac8e-4147-9c02-61d261915473	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
8063310d-4357-4a6f-acbc-33f97c7d709a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	6ea8a7d7-ac8e-4147-9c02-61d261915473	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
7d8e9df7-570f-4968-8549-c184bc99a68c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	68d0961b-502b-4604-8e54-8762c6c30842	\N	NEW	aa1a0cdc-8202-4654-a28e-9bda086a3f84	\N	\N
7d03c968-5561-42cd-ad8c-ff1444b5640b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	68d0961b-502b-4604-8e54-8762c6c30842	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
8b7389ba-c954-4dfa-89f6-0eb489788cb7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	68d0961b-502b-4604-8e54-8762c6c30842	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
ff624737-5677-4f8f-831b-51316c934047	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	26b6ba40-8343-4c66-bff1-36564a39e42b	\N	NEW	61b1fbb4-305b-406d-8906-b48d47be9faf	\N	\N
bfd1e099-df1b-4980-8af2-17305f501c87	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc655b42-2179-459b-bec9-b05a3441a608	\N	NEW	d4c313e9-9190-43d3-9280-4e19a3619f44	\N	\N
f7c543e9-34cf-4fda-8b9a-e75824e036b1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc655b42-2179-459b-bec9-b05a3441a608	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
4fa7fa43-b1f9-451d-ad8d-9d77b0448b8e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f3e6ae59-9477-407f-8b0c-434a311ad62a	\N	NEW	d2d93c15-e9a1-4bd4-bd69-67fd18be74c8	\N	\N
737f1459-798f-467d-8580-5bf41a8320a6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	68389337-be46-424e-90e9-58078a7aa2ff	\N	NEW	aa1a0cdc-8202-4654-a28e-9bda086a3f84	\N	\N
8ae7a471-739e-4a4d-9c8f-359fd5f0b88c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	68389337-be46-424e-90e9-58078a7aa2ff	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
435241fe-ac44-49ef-8c2e-d360ff7e1ec2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	68389337-be46-424e-90e9-58078a7aa2ff	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
7856d3bb-67c9-432e-9fb0-310bb8ae8336	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	68389337-be46-424e-90e9-58078a7aa2ff	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
86c9651a-faa3-425f-afe9-c5e9ab586228	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	68389337-be46-424e-90e9-58078a7aa2ff	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
eafbd5a2-32f5-4a6a-86cc-6ccabda1ec14	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	23394129-835b-474a-ac6a-e8038f6eb086	\N	NEW	d1c5678e-bd8c-4db0-a303-020d49396e0f	\N	\N
5897fb37-6cc6-44d5-be34-1b173a6bdf16	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	23394129-835b-474a-ac6a-e8038f6eb086	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
14c7f30d-d0c9-43ca-a3e3-b48a8cd9c329	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	23394129-835b-474a-ac6a-e8038f6eb086	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
ed454328-2c79-47fe-888b-cc5b81ddf6f3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	23394129-835b-474a-ac6a-e8038f6eb086	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
9c9edef0-0c49-4d6a-9d7f-ca7cd0cc3954	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	23394129-835b-474a-ac6a-e8038f6eb086	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
ba588b2b-5a58-48f6-bf97-f79362273397	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1e28b01c-64f1-46b5-8df8-9f2d5a747bd3	\N	NEW	071618e8-48df-4397-bf58-13500b13b963	\N	\N
56a15d6f-81a6-4757-9640-4cbc52f1ac3e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1e28b01c-64f1-46b5-8df8-9f2d5a747bd3	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
5543f7e7-af8c-4938-bbfd-a2c34c587e2e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1e28b01c-64f1-46b5-8df8-9f2d5a747bd3	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
b3a57c0c-6864-4888-8b34-fda0b2633afb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b8916ece-b846-4bee-996a-2a8cb1021815	\N	NEW	f4c87468-fa82-45fc-aa90-d3668f808a3b	\N	\N
71bfd6a0-fc61-4ea4-b094-10ad821936ee	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b8916ece-b846-4bee-996a-2a8cb1021815	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
2d6d06b2-6b1d-4a03-8b54-0c378a9c8452	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b8916ece-b846-4bee-996a-2a8cb1021815	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
5cd1db3a-2908-40bd-af66-d7f929efc8b7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b8916ece-b846-4bee-996a-2a8cb1021815	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
2d881012-082a-4068-b24c-e87274a1e368	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b8916ece-b846-4bee-996a-2a8cb1021815	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
04530123-f91d-496b-88db-490bf6a2cae3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5f43f1dd-4ebb-43a8-a928-884c849f8346	\N	NEW	120785d1-cb13-4721-9ef9-0bf3ab8f860f	\N	\N
53262806-864f-422a-b739-0ea7ed723221	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5f43f1dd-4ebb-43a8-a928-884c849f8346	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
22e13490-584f-4c95-a048-6be672f0d6a0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	208717fa-20e8-4b9d-9127-e83e1ff9494b	\N	NEW	38d853ee-2655-4675-94c3-32aa7c6710e9	\N	\N
83ada450-eef5-47fa-987b-d4ddbf02d81e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0a1dba-9420-4a69-a9c6-1410bbb6aca7	\N	NEW	38d853ee-2655-4675-94c3-32aa7c6710e9	\N	\N
aad5cb79-4202-4a4e-bd58-4f4dfd67fb19	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0a1dba-9420-4a69-a9c6-1410bbb6aca7	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ef8bf7c0-d916-4480-a41d-512bbc1fa04c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0a1dba-9420-4a69-a9c6-1410bbb6aca7	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
5705de0e-fe88-4a3a-850f-172d6abee862	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9d0a1dba-9420-4a69-a9c6-1410bbb6aca7	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
0f75f23f-83e5-4f29-b162-6a86f1b9fe3c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d6eb0d69-6608-40ac-bae2-02dfe0049115	\N	NEW	79cdf8e8-d92d-4dd2-ac25-05633943c332	\N	\N
f168a35d-e8c0-40a6-9536-895c1ab575f4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d6eb0d69-6608-40ac-bae2-02dfe0049115	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
7814771b-1286-4260-8330-c46350b64da0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a779a6e4-ab4b-4db7-9d48-c39862b2e451	\N	NEW	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	\N	\N
93e950e8-9631-44ae-9296-6ef9093e79eb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a779a6e4-ab4b-4db7-9d48-c39862b2e451	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
f345df3d-a751-4500-9a55-4d8090044378	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a779a6e4-ab4b-4db7-9d48-c39862b2e451	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
f60e9c54-f0f1-4da8-bd47-4db8bca46e08	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	6aa36a8d-96c3-47ab-9dbb-2115794e0a4f	\N	NEW	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	\N	\N
001350ce-7c9d-48f3-8e50-cd28602bc99f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	89d90361-146b-4b2a-8a40-c918f8b253d4	\N	NEW	61b1fbb4-305b-406d-8906-b48d47be9faf	\N	\N
af2e2d8a-c951-48cc-a45a-13c1e5070d4f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	89d90361-146b-4b2a-8a40-c918f8b253d4	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ea06f57c-b7f7-462d-8434-6c4875de0918	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	89d90361-146b-4b2a-8a40-c918f8b253d4	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
25649824-be23-4fd1-9bc6-158f4912104c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	931274f2-1f1a-4388-ae2e-e6de742b2069	\N	NEW	f8694dbb-a668-4fd2-9e16-0ab2f6c11dac	\N	\N
c54a4474-06d3-4089-b8c6-9987158e1303	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	931274f2-1f1a-4388-ae2e-e6de742b2069	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
501d45bf-9576-451a-9cc4-b978a4093588	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	931274f2-1f1a-4388-ae2e-e6de742b2069	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
d1f5851c-8cb2-4c5b-bd99-8ca9d6568210	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	931274f2-1f1a-4388-ae2e-e6de742b2069	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
5213f5db-a1d6-48f6-9a14-f63b4e44e251	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a81d0f25-22e7-4032-b5bb-e430957c729a	\N	NEW	b4968123-7908-457a-9e7c-2ae17c8fadaa	\N	\N
14c5400f-3b98-478e-b66a-46078ec1ede6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a81d0f25-22e7-4032-b5bb-e430957c729a	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
455a6bd0-ccf7-4ead-ab64-54353661c98f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a81d0f25-22e7-4032-b5bb-e430957c729a	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
45608686-6bbf-48c6-85cc-0a9cd8854111	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a81d0f25-22e7-4032-b5bb-e430957c729a	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
c6aaf2e1-786e-4ca2-95ae-d1a055b40eb1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a81d0f25-22e7-4032-b5bb-e430957c729a	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
e240feee-afcd-4296-80d7-a7214169c704	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0f68a95a-0d8a-418d-9281-b759a1f0a387	\N	NEW	5e21829a-b5e3-4498-bb83-e912d258e2b8	\N	\N
33f65c0f-4ebe-4d7f-8651-e7c77e100ae1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0f68a95a-0d8a-418d-9281-b759a1f0a387	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
59e80fa8-09a2-4eff-9450-1147b8811371	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0f68a95a-0d8a-418d-9281-b759a1f0a387	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
845b6f99-e8e7-48fa-9de0-0a5b708eaa9c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0f68a95a-0d8a-418d-9281-b759a1f0a387	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
65bd947e-dbc9-4e67-8f11-802f6e7f7988	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0f68a95a-0d8a-418d-9281-b759a1f0a387	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
e3237cd9-3604-4a7b-b503-97454038ea4a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bf976497-a5ba-4750-b98d-a8ec07c4a6a7	\N	NEW	ac154839-ac39-455f-a2b1-9ba4efbcbbd5	\N	\N
f0c38622-69d3-4f8b-858f-41ab8ec49ca7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bf976497-a5ba-4750-b98d-a8ec07c4a6a7	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
faae2713-a24f-482c-8bcf-5a9d15b31933	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bf976497-a5ba-4750-b98d-a8ec07c4a6a7	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
46eb6bc8-2c7d-4347-9e67-363c9da0bcfe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bf976497-a5ba-4750-b98d-a8ec07c4a6a7	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
d22dfe34-7327-4733-8711-7dcf517af927	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bf976497-a5ba-4750-b98d-a8ec07c4a6a7	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
8e6898df-e176-4561-8e69-b6b464f2057f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8ac6b5be-9fee-4f17-81e7-5dbdad7a60a2	\N	NEW	9fc4ca33-d77a-452f-aa97-677485aa2285	\N	\N
7046f8f7-ff29-4e14-aaf0-8822e0a8972c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8ac6b5be-9fee-4f17-81e7-5dbdad7a60a2	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
d9c1995b-3b72-4288-a374-e9648616dac1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b5926c78-521f-4c77-9033-4182b962c3a8	\N	NEW	9bd4b184-458f-4eab-9472-6578042407e0	\N	\N
01fcb7da-d69b-495f-8f88-1213a5f87e34	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b5926c78-521f-4c77-9033-4182b962c3a8	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
f3b0ce9c-77f9-4cc6-9870-b47f7cc505c8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b5926c78-521f-4c77-9033-4182b962c3a8	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
08a775e0-b79a-499b-b79a-62c339702379	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b5926c78-521f-4c77-9033-4182b962c3a8	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
41baa8bf-9fde-4200-a81e-cdda21fdd2fe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b5926c78-521f-4c77-9033-4182b962c3a8	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
91b16bec-51c6-420c-be13-063e4dfb6347	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc25e05c-13fa-4471-9308-b62ac137fbbb	\N	NEW	79cdf8e8-d92d-4dd2-ac25-05633943c332	\N	\N
283ad7ea-39d0-482c-b567-65b65914a25a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc25e05c-13fa-4471-9308-b62ac137fbbb	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
fd80f135-0a09-4f24-b200-58aeac168a4a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc25e05c-13fa-4471-9308-b62ac137fbbb	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
e0e5b0ce-615a-4baa-bfde-60b9041d671d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fc25e05c-13fa-4471-9308-b62ac137fbbb	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
102ef6fb-da3b-491c-9b1d-ba6c1bd3c1a4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	feb85454-9b19-4ecb-8ca9-6010b634cd68	\N	NEW	2df7ef09-1682-43c9-9c64-e479c86c1c1e	\N	\N
c63dcb52-bf45-4773-88e9-0fe4efe1f0dd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	483c0bd5-2142-4826-afff-6183f231fc87	\N	NEW	d9361d85-2226-44be-b864-ad171091950c	\N	\N
1da287c7-cade-41ab-8cc1-605f76dd89e8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1c150027-65a6-4c91-8f5f-44071bd82a58	\N	NEW	ec44affc-f5ff-40ef-a3de-b8f303fee488	\N	\N
423c88e5-6da0-4591-9483-c2d83792ad49	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1c150027-65a6-4c91-8f5f-44071bd82a58	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ea2b428c-4858-4e4e-8945-59b52c63f4d0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1c150027-65a6-4c91-8f5f-44071bd82a58	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
8dde5e5e-cdc7-49e0-8e10-440fae04fcaa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1c150027-65a6-4c91-8f5f-44071bd82a58	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
9cbee0cd-581d-4f96-a6e1-dab9219ef2fb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1c150027-65a6-4c91-8f5f-44071bd82a58	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
69fe39d2-ef3d-435c-a6d6-f4c8cbb6e334	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	236e5cdf-677c-47f3-8f93-967b7e56b0fc	\N	NEW	53bde808-7662-4bfc-a407-54fd1b83b4f6	\N	\N
fb70a0e0-c6a2-4aa2-8ca5-8897179577f8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	236e5cdf-677c-47f3-8f93-967b7e56b0fc	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
c4ceb837-0710-47a0-90a0-f30a61cf4db2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	236e5cdf-677c-47f3-8f93-967b7e56b0fc	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
6337611c-178a-4d24-a413-9b69c42025c0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	236e5cdf-677c-47f3-8f93-967b7e56b0fc	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
8c86fc63-3d40-4ffd-a125-ac6d668ceea7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	cc71cc40-a906-49a2-93bf-a3387a19b1fe	\N	NEW	4cb39fa4-be14-4a89-9fae-f88ea5406111	\N	\N
5ae5d1ab-0594-4aad-91d2-9ec0cb38ded5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5f0d98bc-c50e-489e-9231-6afe16b6ca6f	\N	NEW	61e3614b-3b90-47a9-baf7-ecf8e7a6b96c	\N	\N
6fff1d34-8b51-44e9-9cbc-bce120bc602b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5f0d98bc-c50e-489e-9231-6afe16b6ca6f	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
196dc2d1-3681-4a94-8a11-1551fde2618a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7fff1180-17da-442a-88a6-f44dae350d58	\N	NEW	5b91137f-8c0a-403f-8bd3-f26ba765e8a3	\N	\N
3e8a03ed-b8a8-4d68-a843-ca53329953a9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7fff1180-17da-442a-88a6-f44dae350d58	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
1cc3a98c-b85a-46a6-a520-04e0fe2747d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7fff1180-17da-442a-88a6-f44dae350d58	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
03c9e8e1-044e-4731-a1cd-787e72cc3ecc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7fff1180-17da-442a-88a6-f44dae350d58	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
558f7fa2-6e22-41ff-81c2-9d9417e1de25	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7e98fd5a-77ba-44e0-8901-1da35073c345	\N	NEW	71e291b7-f092-40b6-9819-8fc848682e6a	\N	\N
5eaa9516-8d1c-459a-90d0-205fc9a226a0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7e98fd5a-77ba-44e0-8901-1da35073c345	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
e6b6001c-afbd-4208-b617-6fd79c1019fe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7e98fd5a-77ba-44e0-8901-1da35073c345	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
01deccbd-b5b5-444d-810d-ea6e85cdd162	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7e98fd5a-77ba-44e0-8901-1da35073c345	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
eb072b2c-b0fd-4a6c-abde-f5f599378bfa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7e98fd5a-77ba-44e0-8901-1da35073c345	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
929a2fd3-2a94-4057-84cb-bb4c6585d59b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9407bde7-9de3-4826-a260-30f783cbc5b7	\N	NEW	93d899ce-d497-4f95-82b2-fe293db75dc5	\N	\N
a81e1e4e-d625-47fb-944b-c263bea2d4b9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9407bde7-9de3-4826-a260-30f783cbc5b7	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
4458aa78-c8fc-4e00-84ae-37728eb9dabe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9407bde7-9de3-4826-a260-30f783cbc5b7	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
a004d2cb-2ae4-4223-8761-f88ca1f7edac	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5030c55e-5f75-4a1f-8a85-6d1a9e3e1a4b	\N	NEW	407f8619-e786-4515-8bbe-1676e3bbc361	\N	\N
3c403c7b-ea79-498a-b037-baae3cefb774	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5030c55e-5f75-4a1f-8a85-6d1a9e3e1a4b	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
d34c41bd-aa12-449e-9c47-f6cd784220a3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5030c55e-5f75-4a1f-8a85-6d1a9e3e1a4b	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
cc8e3d77-0bdd-49fd-800a-ce9f511dae6a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5030c55e-5f75-4a1f-8a85-6d1a9e3e1a4b	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
87aa8e92-d61d-4fb2-abe8-f2e6afa08efb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5030c55e-5f75-4a1f-8a85-6d1a9e3e1a4b	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
8b420c7c-51e8-4750-8d88-c720392f6540	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e4c02c7d-6f11-4f80-bfb1-d6d5afae6c5a	\N	NEW	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	\N	\N
04afecb5-fbfc-4190-a8f6-4f89d6d1feb1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e4c02c7d-6f11-4f80-bfb1-d6d5afae6c5a	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b5268b58-8557-4ca2-a13b-855b092935b6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e4c02c7d-6f11-4f80-bfb1-d6d5afae6c5a	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
73ae886f-db05-4ac5-a05c-f0b37f22078f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e4c02c7d-6f11-4f80-bfb1-d6d5afae6c5a	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
773c98c4-d285-4d00-9c0a-4f4db477ba2e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	37c0bc43-84ba-4d95-8a02-e53bcacc1fac	\N	NEW	8bcb8775-4b58-4050-85f8-885a9b8b0fe4	\N	\N
c945282d-dc61-4f44-893a-e4f5b80e7b77	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	37c0bc43-84ba-4d95-8a02-e53bcacc1fac	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
17fc251d-fd49-4fec-bb76-233b9ed057ec	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	37c0bc43-84ba-4d95-8a02-e53bcacc1fac	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
6ef014ac-eef4-4f64-9c13-e4502c5b74b9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	66a653ee-0761-4996-9c99-ee1293d9c38e	\N	NEW	12ad4336-b729-4548-8029-c4282d7fb413	\N	\N
66a86589-3675-4ffc-984b-0f5fccbd1058	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	66a653ee-0761-4996-9c99-ee1293d9c38e	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
3b91ed24-6c5d-4c75-a4f2-d29f34f64196	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	66a653ee-0761-4996-9c99-ee1293d9c38e	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
764b8eb0-4f03-43d7-99dc-cbc5e3fed54f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	66a653ee-0761-4996-9c99-ee1293d9c38e	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
ca57a179-6588-4685-914f-e53486772c28	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1b047d97-85bd-4e7a-965f-f633812b4b90	\N	NEW	3a55a2a5-5792-4cac-8d1a-f89f2636b489	\N	\N
929812af-a1f9-478b-b223-b24d2fd3b77f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1b047d97-85bd-4e7a-965f-f633812b4b90	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
df0ab65f-3537-4c80-9ad7-ed820cb48d29	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1b047d97-85bd-4e7a-965f-f633812b4b90	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
f4b4826c-4710-47ef-a000-9402f2252592	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1b047d97-85bd-4e7a-965f-f633812b4b90	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
dc66108f-1343-412f-ab14-dedc1da55918	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1b047d97-85bd-4e7a-965f-f633812b4b90	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
964f1f94-dde5-4885-abed-87e1e7643072	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	690dd591-946e-40d6-a86d-e53ab0e4c381	\N	NEW	79cdf8e8-d92d-4dd2-ac25-05633943c332	\N	\N
89b6629e-2035-4762-b17c-5beef90de184	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	690dd591-946e-40d6-a86d-e53ab0e4c381	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
acf1667a-4447-49e1-90cb-8d78b4dd704d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	690dd591-946e-40d6-a86d-e53ab0e4c381	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
5b58e86e-f4d4-4270-a7ac-2fbe037a16af	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	690dd591-946e-40d6-a86d-e53ab0e4c381	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
6c932db6-7e5e-4ca2-a2e9-d50bdea64f9a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	690dd591-946e-40d6-a86d-e53ab0e4c381	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
a35793b8-3162-4ff4-a739-bab0d309e90f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bedb9461-fc70-49d0-b05f-7c9c3629f37b	\N	NEW	61b1fbb4-305b-406d-8906-b48d47be9faf	\N	\N
04e1280a-278e-4352-a671-8c7fc21c7ab1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bedb9461-fc70-49d0-b05f-7c9c3629f37b	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
5c84aa2c-e7fe-4aca-9f5e-fa174ee02bbc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bedb9461-fc70-49d0-b05f-7c9c3629f37b	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
77f1164d-4085-418f-9ede-5c052b2c4632	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	33e7df9f-f7a1-43a2-b2cc-42a271858a28	\N	NEW	53e744ac-828b-41ed-b12a-34f7829c1e38	\N	\N
21167a74-e340-48ab-bc47-121f85f11527	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	33e7df9f-f7a1-43a2-b2cc-42a271858a28	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
4c330136-c8fd-419a-9d2a-4a151b0840d1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	33e7df9f-f7a1-43a2-b2cc-42a271858a28	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
d68bf8dd-0aa1-4ee5-a785-a4a722372afb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	33e7df9f-f7a1-43a2-b2cc-42a271858a28	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
8f067a65-d011-4dc9-acd1-207634dafbc8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	33e7df9f-f7a1-43a2-b2cc-42a271858a28	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
715ef3a5-4d87-4847-a239-12887f0e9324	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	df1168d7-0ed2-445e-939a-3e2dce9e53d8	\N	NEW	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	\N	\N
b48720a0-e31a-473f-87b6-8e7234c54b06	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	df1168d7-0ed2-445e-939a-3e2dce9e53d8	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
cb906d7b-1a97-4a11-bde0-738377f57ca9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	df1168d7-0ed2-445e-939a-3e2dce9e53d8	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
dc8bbf4f-3121-49d8-b867-a67ae91c6060	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	df1168d7-0ed2-445e-939a-3e2dce9e53d8	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
5cd4b0cd-b8ce-49bb-aa0a-605d8ffa4b57	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	df1168d7-0ed2-445e-939a-3e2dce9e53d8	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work completed	\N
a20321f3-2966-4e7b-b27a-bd9e6724d3db	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	760a6445-68be-41d6-82b4-1adf05a2b0bb	\N	NEW	98c7399e-0621-457a-b93b-d8eeaaac4630	\N	\N
1095a0e7-6791-4aea-a80e-259a9e8e9939	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fe2c5289-ac68-4fd6-9904-8cfbaffbe9e3	\N	NEW	8eb63fe5-7d76-48a0-9456-36d698f469ed	\N	\N
8fa2fbd6-6432-4436-976d-dcc5b0b06ee8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fe2c5289-ac68-4fd6-9904-8cfbaffbe9e3	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ecbdf883-911d-4ff8-8b1f-4630152a373b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fe2c5289-ac68-4fd6-9904-8cfbaffbe9e3	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
60f06ead-cb29-4724-9373-1a46dbcaa64c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fe2c5289-ac68-4fd6-9904-8cfbaffbe9e3	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
58df565b-3d1b-48c7-9bc0-1676e34aca1e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fe2c5289-ac68-4fd6-9904-8cfbaffbe9e3	IN_PROGRESS	ON_HOLD	be3cf16a-1466-4065-a1b0-47ff590bc0b4	\N	\N
68a586d8-7cf6-4e90-9203-470ec49b3d17	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c24e31e5-6c8b-43ff-ac28-08ba1832e18b	\N	NEW	676ad3ae-87fa-4a38-8bf7-2debba141c77	\N	\N
d7b983bd-ea3e-4c73-b013-15cd3d3f69c9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c24e31e5-6c8b-43ff-ac28-08ba1832e18b	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
b4613a4f-618f-4ede-97ea-b9db6be8718f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c24e31e5-6c8b-43ff-ac28-08ba1832e18b	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
74373de9-2616-4b42-89ca-3276b9a12b1b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	010e69b7-e264-4d7b-91dc-ea5e405bbfca	\N	NEW	b18189ca-de52-4473-abc4-4e019eb74fef	\N	\N
d85224e8-60ae-4343-a3db-21474afda309	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	010e69b7-e264-4d7b-91dc-ea5e405bbfca	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
fdf38986-258a-4a03-9c0c-28144f683c55	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	010e69b7-e264-4d7b-91dc-ea5e405bbfca	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
d5397eda-027c-4454-aeba-be4f5f31add3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	726af69c-4df6-468a-adb8-7eaed6b39a2c	\N	NEW	071618e8-48df-4397-bf58-13500b13b963	\N	\N
ea6f5049-d519-411d-834f-d061e7727e08	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	726af69c-4df6-468a-adb8-7eaed6b39a2c	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
095a5a36-6faf-45bc-91b7-ebd072141656	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	726af69c-4df6-468a-adb8-7eaed6b39a2c	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
66a9353c-fc45-4ae0-8d0e-807407c0ca3b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	726af69c-4df6-468a-adb8-7eaed6b39a2c	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
4abc7811-1dba-40f3-8c3a-b08a7add2d25	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	726af69c-4df6-468a-adb8-7eaed6b39a2c	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
1f15e416-4aba-425a-9283-3e2c775df896	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	aaa499ab-e07f-441a-be77-6305ecf7220f	\N	NEW	5fb6cc19-15bc-43c0-82ad-5a55f3ddf1db	\N	\N
f2d71f8f-50b8-45c2-a4cf-d9f10791c817	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	aaa499ab-e07f-441a-be77-6305ecf7220f	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
c23410ef-5c05-448c-b07a-e1ba380df1c4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2b3a65f7-06fe-4e86-8aa2-8a412edc2dcc	\N	NEW	b1469661-e285-4513-ac3d-fffcc131daa6	\N	\N
992783c5-cbad-4bdf-b0ad-24a2a2c6bc0b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2b3a65f7-06fe-4e86-8aa2-8a412edc2dcc	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
766ec473-8299-4c18-a755-ae37906ebf3f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2b3a65f7-06fe-4e86-8aa2-8a412edc2dcc	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
8ab7abcc-c78a-4d15-9d3a-8b25b0a525d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2b3a65f7-06fe-4e86-8aa2-8a412edc2dcc	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
adbd3d4b-69a1-4fc5-bbda-04374a9874d4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2b3a65f7-06fe-4e86-8aa2-8a412edc2dcc	IN_PROGRESS	ON_HOLD	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
875c5b0d-f8da-42b1-aa9d-9cabc7dfed2c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1976a796-bba2-4866-8e31-ccdc5f1d74b1	\N	NEW	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	\N	\N
eca9cf76-eec7-40c7-956e-bc85866853e9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1976a796-bba2-4866-8e31-ccdc5f1d74b1	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
cef69fb2-90c0-4bef-9a99-8a041b0998e0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1976a796-bba2-4866-8e31-ccdc5f1d74b1	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
4110349a-b189-4d88-959f-46742a6b9ed2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1976a796-bba2-4866-8e31-ccdc5f1d74b1	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
51b64683-2160-4c15-813a-e31dbb5a2217	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	690f0596-52d5-4dda-8828-c9dccd8a66e6	\N	NEW	4fd836c0-e4b7-4de5-ae7d-57a9d29b7325	\N	\N
9bd5821b-566e-4eeb-8972-2f2c3d30b100	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	690f0596-52d5-4dda-8828-c9dccd8a66e6	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
8672ffc5-7f08-453d-b4ad-04d9c8f7b265	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c39b6048-33b7-42f7-bdd6-589b7fe61acd	\N	NEW	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	\N	\N
6147b5c4-1c08-4af0-9a0b-5612da36fb2a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c39b6048-33b7-42f7-bdd6-589b7fe61acd	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
ed6f25ac-7828-4a17-92a6-3586d1c6ab10	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c39b6048-33b7-42f7-bdd6-589b7fe61acd	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to Jane Technician	\N
9eb91ef9-00f9-4d30-bc9b-2c97b117081c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c39b6048-33b7-42f7-bdd6-589b7fe61acd	ASSIGNED	IN_PROGRESS	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work started	\N
de55b8b2-45c4-43c7-a780-a9cdb9b04723	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c39b6048-33b7-42f7-bdd6-589b7fe61acd	IN_PROGRESS	COMPLETED	be3cf16a-1466-4065-a1b0-47ff590bc0b4	Work completed	\N
5f024c80-8da5-49f3-8290-f345cd714df7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	96bf4f85-c7ed-4d32-9f2c-388ea3a156f3	\N	NEW	93d899ce-d497-4f95-82b2-fe293db75dc5	\N	\N
f6cc97d8-2787-4c11-855b-a2154850ed31	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	96bf4f85-c7ed-4d32-9f2c-388ea3a156f3	NEW	ACKNOWLEDGED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Ticket acknowledged by site coordinator	\N
7590757b-c68f-4020-ac19-d5af4e55a42f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	96bf4f85-c7ed-4d32-9f2c-388ea3a156f3	ACKNOWLEDGED	ASSIGNED	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	Assigned to John Technician	\N
b9a49268-1e25-4f85-a1b5-b8b91f1ed188	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	96bf4f85-c7ed-4d32-9f2c-388ea3a156f3	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Work started	\N
16dc8604-4024-4f6b-832c-169e0ed17a6f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:44:53.849409	2025-12-23 15:44:53.849409	74b948e0-74b4-48d9-b0bd-45532750eaa9	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
b83245a2-f295-4415-bcb5-c9cda817e3b7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:04:24.402155	2025-12-24 12:04:24.402155	d7ef6216-24cc-47fb-9c12-d0a3e3f788e0	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
33dac91d-f8a0-4280-a534-722c5c5833a5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:09:24.258826	2025-12-24 12:09:24.258826	9dc8bae4-aad4-494d-8183-43b4045abb45	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
4578621a-b02e-430e-b40a-7106df2ec8f2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 18:01:11.936902	2025-12-24 18:01:11.936902	9dc8bae4-aad4-494d-8183-43b4045abb45	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
af645aee-e068-4f4c-a41c-81b798550eca	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 18:04:57.105759	2025-12-24 18:04:57.105759	9dc8bae4-aad4-494d-8183-43b4045abb45	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician2@villa-maintenance.com	\N
e088e163-81e6-4d34-9a09-0d41b709b4d2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 18:18:14.02526	2025-12-24 18:18:14.02526	9dc8bae4-aad4-494d-8183-43b4045abb45	ASSIGNED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
4ebdfae1-3044-4376-894d-06df4d23d305	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:52:12.959638	2025-12-24 22:52:12.959638	6741b8c0-317c-4746-8ef3-3c89028ee0da	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
24491f79-ecc7-4c9c-bd7b-995b47aeca98	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:52:47.386794	2025-12-24 22:52:47.386794	6741b8c0-317c-4746-8ef3-3c89028ee0da	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
2fe6d01b-d42b-4f59-a8fb-75e3e398bd99	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:53:02.536323	2025-12-24 22:53:02.536323	6741b8c0-317c-4746-8ef3-3c89028ee0da	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
dc04afa9-402c-4b65-ab6b-7653afbffa1b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:54:30.589924	2025-12-24 22:54:30.589924	6741b8c0-317c-4746-8ef3-3c89028ee0da	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
fb732280-a727-4e75-bbf2-30e13ba8e496	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:56:01.026554	2025-12-24 22:56:01.026554	6741b8c0-317c-4746-8ef3-3c89028ee0da	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	Completed	\N
b9a61e45-75fc-47d3-9861-9a79b2435405	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 22:56:23.723967	2025-12-24 22:56:23.723967	6741b8c0-317c-4746-8ef3-3c89028ee0da	COMPLETED	COMPLETED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Tenant confirmed completion	\N
37fc65d6-97ac-43df-a7c2-0fdf78ef7405	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:44:22.504011	2025-12-26 10:44:22.504011	b214eadc-297e-4e34-beef-c3e177c4fd3f	\N	NEW	44142ebb-779d-4e83-b0a2-3db691e389ff	Ticket created	\N
9057ce07-14d4-47ca-a0d9-4ca52f237c48	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:48:47.814253	2025-12-26 10:48:47.814253	b214eadc-297e-4e34-beef-c3e177c4fd3f	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
8dd11dff-e4ae-4214-bb4f-10e2e1d7aa36	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:49:12.82812	2025-12-26 10:49:12.82812	b214eadc-297e-4e34-beef-c3e177c4fd3f	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
37716198-c627-4555-845d-6b431edd82dd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:51:27.237874	2025-12-26 10:51:27.237874	b214eadc-297e-4e34-beef-c3e177c4fd3f	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
9e94fc90-9b49-4d68-add4-fb18a362ec90	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:53:06.72921	2025-12-26 10:53:06.72921	b214eadc-297e-4e34-beef-c3e177c4fd3f	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	resolved	\N
e3b04fbd-f651-465d-a491-519d20caeb06	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:54:59.637693	2025-12-26 10:54:59.637693	b214eadc-297e-4e34-beef-c3e177c4fd3f	COMPLETED	COMPLETED	44142ebb-779d-4e83-b0a2-3db691e389ff	Tenant confirmed completion	\N
41685012-90c1-4119-9d94-cfecfba5f2c2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:24:19.122499	2025-12-26 15:24:19.122499	6d35f6db-4ebc-4a21-992d-bc17bd67f715	\N	NEW	44142ebb-779d-4e83-b0a2-3db691e389ff	Ticket created	\N
a36e9aa4-4f3a-4062-b13e-abd0dd403e65	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:38:36.264166	2025-12-26 15:38:36.264166	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	\N	NEW	44142ebb-779d-4e83-b0a2-3db691e389ff	Ticket created	\N
eca7169c-4ff7-436f-b737-c2ce18927a37	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:44:35.144056	2025-12-26 15:44:35.144056	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
c5fd7305-315c-4233-be7e-35707cbb07ef	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 15:44:40.223277	2025-12-26 15:44:40.223277	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
aa0406f4-4594-42e6-8a0f-76fd773858eb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:02:47.404832	2025-12-26 16:02:47.404832	107b8dc1-166c-482e-b7cb-6cdbe56c9d8e	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
1b45f53d-7dd4-4349-bbb4-3e9e63e52932	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:47:54.471385	2025-12-26 16:47:54.471385	05facf4d-61bf-4457-bdfd-fd17ce140971	\N	NEW	d105993f-6f85-4144-ba14-dd361ae6df2e	Ticket created	\N
a1718d5b-8319-4029-80b0-8cb3811aea96	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:49:06.605655	2025-12-26 16:49:06.605655	05facf4d-61bf-4457-bdfd-fd17ce140971	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
9cc9a53a-9f43-4a28-ae49-6df3aa56fb04	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:49:22.642832	2025-12-26 16:49:22.642832	05facf4d-61bf-4457-bdfd-fd17ce140971	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
29b97434-be2d-40b3-b85b-c441ace0a72f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:50:32.767858	2025-12-26 16:50:32.767858	05facf4d-61bf-4457-bdfd-fd17ce140971	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
3c158201-4445-4746-afee-6fb0a1ac6e17	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:51:23.735796	2025-12-26 16:51:23.735796	05facf4d-61bf-4457-bdfd-fd17ce140971	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	resolved	\N
5af5e52e-17e5-44e1-afb2-a21114789241	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:52:18.754546	2025-12-26 16:52:18.754546	05facf4d-61bf-4457-bdfd-fd17ce140971	COMPLETED	COMPLETED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Tenant confirmed completion	\N
b01e8b2a-0b4a-4624-b6dc-da486d920715	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:00:34.58292	2025-12-26 17:00:34.58292	718a30f0-863e-402b-a131-e3c341cdefbc	\N	NEW	d105993f-6f85-4144-ba14-dd361ae6df2e	Ticket created	\N
4fd49e0b-fa3c-4bc9-a188-4c79e473aad8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:00:47.294679	2025-12-26 17:00:47.294679	718a30f0-863e-402b-a131-e3c341cdefbc	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
dce4ef43-8dfa-4d3b-b1e5-19e76d290630	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:00:49.877036	2025-12-26 17:00:49.877036	718a30f0-863e-402b-a131-e3c341cdefbc	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
b93e30fd-1239-425d-9d8c-3fc9c1bbe0c2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:01:56.760521	2025-12-26 17:01:56.760521	718a30f0-863e-402b-a131-e3c341cdefbc	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
009482fa-06b9-4377-b2f5-d2b60b991f0f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:02:03.075289	2025-12-26 17:02:03.075289	718a30f0-863e-402b-a131-e3c341cdefbc	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	done	\N
be9ce5f5-784d-497b-b147-f1c725215aa4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:02:36.940446	2025-12-26 17:02:36.940446	718a30f0-863e-402b-a131-e3c341cdefbc	COMPLETED	COMPLETED	d105993f-6f85-4144-ba14-dd361ae6df2e	Tenant confirmed completion	\N
f6f81deb-01b8-40b0-931f-964f3ba3aca5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:18:13.143926	2025-12-26 17:18:13.143926	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	\N	NEW	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	Ticket created	\N
961ffd6e-f400-4ce0-bccc-714842542d29	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:19:20.439227	2025-12-26 17:19:20.439227	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
da47a032-9f26-47e4-8a24-d4e79f3612cd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:19:27.55895	2025-12-26 17:19:27.55895	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
059b9be1-9bd7-4160-9a36-d0b577448c16	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:20:14.609981	2025-12-26 17:20:14.609981	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
cf303e9f-7bdb-4809-be5a-607d1657a9fa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:20:32.051934	2025-12-26 17:20:32.051934	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	resolved	\N
0bce7371-b6b0-4900-9643-2309adb6b85c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:20:55.578673	2025-12-26 17:20:55.578673	443b5e2c-f2bd-4554-9c54-ab7cfe13dc1b	COMPLETED	COMPLETED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Tenant confirmed completion	\N
50f59420-baa4-4a3e-8b28-219003c93492	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:46:18.372787	2025-12-26 17:46:18.372787	91f281b9-f724-4226-b12e-062f987dc6d8	\N	NEW	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	Ticket created	\N
565f5aa6-9e2e-4853-a297-dcc1913c427e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:46:53.066285	2025-12-26 17:46:53.066285	91f281b9-f724-4226-b12e-062f987dc6d8	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
3e1d11b3-d869-4ce9-97f8-f90be8b39345	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:46:56.150525	2025-12-26 17:46:56.150525	91f281b9-f724-4226-b12e-062f987dc6d8	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
92854589-dc18-4d15-9767-0dce578a044a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:47:56.870552	2025-12-26 17:47:56.870552	91f281b9-f724-4226-b12e-062f987dc6d8	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
aa01f5c0-ac75-4eb2-8eab-63095a244835	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:48:02.748833	2025-12-26 17:48:02.748833	91f281b9-f724-4226-b12e-062f987dc6d8	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	completed	\N
7a75695c-c39c-4106-961f-6f496d4c1754	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:48:36.214202	2025-12-26 17:48:36.214202	91f281b9-f724-4226-b12e-062f987dc6d8	COMPLETED	COMPLETED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Tenant confirmed completion	\N
b567d325-3898-4366-93c4-be9d2f61847a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:17:53.97406	2025-12-26 18:17:53.97406	f22f9ddc-e255-4310-b37d-f607174bc053	\N	NEW	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	Ticket created	\N
c8272929-5976-4d38-8ddc-61e3ccea363d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:19:23.195436	2025-12-26 18:19:23.195436	f22f9ddc-e255-4310-b37d-f607174bc053	NEW	ACKNOWLEDGED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Ticket acknowledged	\N
c82c2139-360e-44bc-bcbc-b32a0190047a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:19:30.215364	2025-12-26 18:19:30.215364	f22f9ddc-e255-4310-b37d-f607174bc053	ACKNOWLEDGED	ASSIGNED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Assigned to technician technician1@villa-maintenance.com	\N
c66d5a5c-3571-49b8-af44-6ae72b288af8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:22:44.018212	2025-12-26 18:22:44.018212	f22f9ddc-e255-4310-b37d-f607174bc053	ASSIGNED	IN_PROGRESS	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	\N	\N
e56fc661-702c-46dd-88bb-858e8448236d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:22:56.056665	2025-12-26 18:22:56.056665	f22f9ddc-e255-4310-b37d-f607174bc053	IN_PROGRESS	COMPLETED	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	resolved	\N
88853122-18c3-480d-8308-94751b421fc4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:25:04.379987	2025-12-26 18:25:04.379987	f22f9ddc-e255-4310-b37d-f607174bc053	COMPLETED	COMPLETED	3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	Tenant confirmed completion	\N
1ce46148-76bf-4aab-8b88-0a38401631fa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:49:14.883892	2025-12-30 12:49:14.883892	bd53d25e-e200-4720-9c48-b33871e16a95	\N	NEW	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	Ticket created	\N
52fb9f2d-3786-4a80-996c-3b9072e28799	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:55:48.370108	2025-12-30 17:55:48.370108	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
ce909114-c338-4b35-ba19-6e2a7a40734b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:01:30.516444	2025-12-30 18:01:30.516444	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	NEW	NEW	44142ebb-779d-4e83-b0a2-3db691e389ff	Assigned to technician technician2@villa-maintenance.com	\N
d547b803-1593-40db-bb3b-efbebb013f0a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:01:31.329348	2025-12-30 18:01:31.329348	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	NEW	ACKNOWLEDGED	44142ebb-779d-4e83-b0a2-3db691e389ff	Ticket acknowledged	\N
2541a1ed-bc5d-416a-a5cc-d7dc7958e1b7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:01:31.44702	2025-12-30 18:01:31.44702	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	NEW	ACKNOWLEDGED	44142ebb-779d-4e83-b0a2-3db691e389ff	Ticket acknowledged	\N
9c5f0f95-3779-40a3-916a-8424ca5f6b4c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:01:42.758935	2025-12-30 18:01:42.758935	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	ACKNOWLEDGED	ASSIGNED	44142ebb-779d-4e83-b0a2-3db691e389ff	\N	\N
a90f0a12-7ee7-4c2c-9573-fa7a9064e183	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:01:47.352301	2025-12-30 18:01:47.352301	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	ASSIGNED	IN_PROGRESS	44142ebb-779d-4e83-b0a2-3db691e389ff	\N	\N
2465739c-d276-4fa9-aa45-f6690ee28322	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:01:58.635346	2025-12-30 18:01:58.635346	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	IN_PROGRESS	COMPLETED	44142ebb-779d-4e83-b0a2-3db691e389ff	\N	\N
076d8312-efc0-4951-9c21-f405771bad17	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:08:47.449068	2025-12-30 18:08:47.449068	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	COMPLETED	COMPLETED	44142ebb-779d-4e83-b0a2-3db691e389ff	Tenant confirmed completion	\N
ef977204-a31a-4931-aa09-68676daf54f5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 18:13:44.571891	2025-12-30 18:13:44.571891	0b37442e-a901-48e9-ba00-bc7bf49c3a1d	COMPLETED	COMPLETED	95791439-c679-4dec-98cf-1eccedd65a87	Tenant rated ticket: 4 stars	\N
b6bacd9d-b93a-439c-b2a4-8d63dc5934f8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:02:03.974219	2025-12-31 10:02:03.974219	419cd45a-d38d-4859-8043-cbfe96db48b0	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
ad21bc23-3229-4fc0-9aa6-475eeaedc6de	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-31 10:03:53.199454	2025-12-31 10:03:53.199454	553788fb-7388-434c-b04c-be87691d4ecc	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
34b30ec8-3416-4028-91ca-52cf9e2bb41e	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:41:55.264449	2026-01-01 07:41:55.264449	04be10c5-23c9-4299-befd-94632df7e182	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
a0312641-3ef5-40ea-903d-f1edde171b46	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:51:22.292518	2026-01-01 07:51:22.292518	b3167e24-7241-4858-b78d-75affe56707f	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
86aa1fd2-8798-479b-8082-15c745b40ee5	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 07:57:47.717526	2026-01-01 07:57:47.717526	518a030e-4357-4aaa-b019-03657ca5e722	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
6d7d02cd-1abd-49f8-9dd7-e80b69ea799e	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:04:27.097926	2026-01-01 08:04:27.097926	db1f2cb5-59c4-4e04-a340-ac894fc68772	\N	NEW	95791439-c679-4dec-98cf-1eccedd65a87	Ticket created	\N
42595374-ee9e-42f0-a593-a389f3105eab	eb75a65b-055f-4408-a58c-71d233443c17	2026-01-01 08:29:57.256005	2026-01-01 08:29:57.256005	db1f2cb5-59c4-4e04-a340-ac894fc68772	NEW	CANCELLED	95791439-c679-4dec-98cf-1eccedd65a87	Ticket cancelled	\N
\.


--
-- TOC entry 4407 (class 0 OID 66655)
-- Dependencies: 245
-- Data for Name: user_devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_devices (id, company_id, user_id, fcm_token, platform, device_info, is_active, last_used_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4385 (class 0 OID 65576)
-- Dependencies: 223
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_roles (id, company_id, created_at, updated_at, user_id, role_id) FROM stdin;
1f881f89-b4af-4b75-9042-518f704eaf7e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bfa1c651-6d51-417f-a8bd-2130dd3bc28c	9ea16b07-ccf5-424f-be93-640f37b809a4
a560399e-d6cc-44ec-b0e9-eab8d18e9177	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4ecb4192-9e6a-410d-9cc5-7037a5a104eb	70dd98cb-2806-4079-ad98-c4d605611e58
d4076aa1-8a19-4ac2-81bb-3cee8c4b51bd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1d97134a-1b6a-47da-b3da-9324aa1a2f69	cc869775-11cb-4a30-a846-79edbe15812d
0714c7eb-2fec-4103-b47e-48292442aafa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	26fb3c7e-5d31-490e-8f69-a96c53c96bcc	cc869775-11cb-4a30-a846-79edbe15812d
47e123d5-2fad-491e-ab46-370efdb5252f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5fb6cc19-15bc-43c0-82ad-5a55f3ddf1db	cc869775-11cb-4a30-a846-79edbe15812d
5d8edb8a-2a6b-41a6-9323-1f10fc2721d8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b1469661-e285-4513-ac3d-fffcc131daa6	cc869775-11cb-4a30-a846-79edbe15812d
0fd9c5ea-e2fe-43b9-8e6b-23c609f830b1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	be7c2045-9191-4083-86c2-383c166520bc	cc869775-11cb-4a30-a846-79edbe15812d
e876f57d-7108-4c06-adc9-4eff56524933	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	aa1a0cdc-8202-4654-a28e-9bda086a3f84	cc869775-11cb-4a30-a846-79edbe15812d
38654a57-5851-44f1-b76f-14bf6e6661af	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2c4ad4f5-3790-4cba-b383-bab4e583109f	cc869775-11cb-4a30-a846-79edbe15812d
f9fd6dce-e2b5-42ec-b53c-5d0a283feb1c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	71e291b7-f092-40b6-9819-8fc848682e6a	cc869775-11cb-4a30-a846-79edbe15812d
202938d9-a05e-40fa-a1a7-802f852cd00d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	390bd96a-c854-416d-8660-802e754dfe30	cc869775-11cb-4a30-a846-79edbe15812d
89137782-b43a-4d27-8408-320752f207c2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0eb03419-5169-4605-a380-679a5d9faf95	cc869775-11cb-4a30-a846-79edbe15812d
2d20684f-d654-45f1-a094-e899de6fd802	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d1c5678e-bd8c-4db0-a303-020d49396e0f	cc869775-11cb-4a30-a846-79edbe15812d
241f216a-f00f-4958-8c29-6371627b5c1a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	071618e8-48df-4397-bf58-13500b13b963	cc869775-11cb-4a30-a846-79edbe15812d
057df1f4-3f38-4db2-80a5-c9e8f2a2927e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5ae848af-e1e2-4dc3-a14d-c8a5396b824e	cc869775-11cb-4a30-a846-79edbe15812d
fd83bfea-8023-4f6c-b260-6695430acc87	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ccdaf2d6-3905-4d04-b7a9-c6ac5c3ac2d0	cc869775-11cb-4a30-a846-79edbe15812d
23271fb7-2e73-47ff-8b37-6b537ca575f6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f008eb79-35b9-4af7-95f3-0c136cb32b13	cc869775-11cb-4a30-a846-79edbe15812d
c5ae0c77-b8aa-4049-bc9c-739f50090bdf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8eb63fe5-7d76-48a0-9456-36d698f469ed	cc869775-11cb-4a30-a846-79edbe15812d
f1c87b4b-7a24-483f-9072-485a2f15905c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9bd4b184-458f-4eab-9472-6578042407e0	cc869775-11cb-4a30-a846-79edbe15812d
15d8cb5b-a59a-4a0d-9bad-777bcc026ffc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3eed5386-cd3b-4312-85df-bc01d2f385a6	cc869775-11cb-4a30-a846-79edbe15812d
6331bd69-5514-480d-9c03-74b6c2a5e6f4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	8bcb8775-4b58-4050-85f8-885a9b8b0fe4	cc869775-11cb-4a30-a846-79edbe15812d
cc0d609b-73be-4af3-bb2f-ec7be201a40d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b4968123-7908-457a-9e7c-2ae17c8fadaa	cc869775-11cb-4a30-a846-79edbe15812d
37d3728d-203f-4656-b171-a0c1e9e5a5d1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	60803f2d-364d-4286-8fdc-8248485b9b82	cc869775-11cb-4a30-a846-79edbe15812d
bb38a6b3-a2d0-48a7-9af1-4cd738117ede	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	407f8619-e786-4515-8bbe-1676e3bbc361	cc869775-11cb-4a30-a846-79edbe15812d
da47919c-d756-4083-8472-a0642fb8af0a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	398a1e8a-ff59-49d9-a52f-86d0270964ff	cc869775-11cb-4a30-a846-79edbe15812d
55101375-7b5f-4505-877a-3d97d2cf5926	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	457cc731-4a14-462c-bba5-c0a67fe2b0e4	cc869775-11cb-4a30-a846-79edbe15812d
93b87070-a03e-444c-a7e6-970971ac5557	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	fd842408-0197-42b3-b459-d674809b1276	cc869775-11cb-4a30-a846-79edbe15812d
893de6ad-f8be-4b2f-b888-261e22ce6715	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	15524c37-d38a-415f-b2d9-1f5eecbbdee8	cc869775-11cb-4a30-a846-79edbe15812d
086e0ca7-310f-4555-9a30-d80dea51262e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b18189ca-de52-4473-abc4-4e019eb74fef	cc869775-11cb-4a30-a846-79edbe15812d
fc71551f-d742-4556-8618-e291c350d306	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2882fe7b-13dd-4184-94da-d8b80c2a06c7	cc869775-11cb-4a30-a846-79edbe15812d
4a102c69-6751-40d6-a8a5-9515f89aa9f6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d06fa247-c417-4f2e-9563-0adf28a21f44	cc869775-11cb-4a30-a846-79edbe15812d
632b5ab4-fb5a-4dee-b047-e333233ae400	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	148547a8-d99f-4fb4-bb01-5bb7c6f2b159	cc869775-11cb-4a30-a846-79edbe15812d
a7f5b2d0-12a6-484f-8d64-ead9ee9ade8f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	cfb8af0f-11c6-464b-8e84-747f9cbdcb84	cc869775-11cb-4a30-a846-79edbe15812d
ec4fb012-abc6-4b3b-a8cb-ee48cba55d22	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	03b5e215-5057-405c-9ba4-a3485b1d0c89	cc869775-11cb-4a30-a846-79edbe15812d
40d503b1-7ad0-4b31-b7a8-ae9d73fa686f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f8a34b8b-b250-4c8d-b45a-a09522f0b34b	cc869775-11cb-4a30-a846-79edbe15812d
cde71ecb-f378-46c7-b9e2-e71e5485b08d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	42264350-62a4-4119-b213-4e2f68ebe513	cc869775-11cb-4a30-a846-79edbe15812d
99d5d1d5-5b6e-45c2-8084-5540201230b6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	61e3614b-3b90-47a9-baf7-ecf8e7a6b96c	cc869775-11cb-4a30-a846-79edbe15812d
f2956b12-4c51-4630-9559-d810e26c8fb9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	2df7ef09-1682-43c9-9c64-e479c86c1c1e	cc869775-11cb-4a30-a846-79edbe15812d
f9ae139a-2c70-405a-a788-a2a6a6399c45	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4cb39fa4-be14-4a89-9fae-f88ea5406111	cc869775-11cb-4a30-a846-79edbe15812d
ff62fe12-c5a2-43aa-aab7-65662abd279c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	120785d1-cb13-4721-9ef9-0bf3ab8f860f	cc869775-11cb-4a30-a846-79edbe15812d
b3b72d56-f924-406c-bcbe-c5100cdbd61d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	38a4ff0d-a3ad-4c48-b4e1-02706892b17d	cc869775-11cb-4a30-a846-79edbe15812d
b56b36f4-cb45-4bc4-8cfe-775a1f059726	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d4c313e9-9190-43d3-9280-4e19a3619f44	cc869775-11cb-4a30-a846-79edbe15812d
8ac6976e-d6af-450d-baf5-e179df3b6244	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	93d899ce-d497-4f95-82b2-fe293db75dc5	cc869775-11cb-4a30-a846-79edbe15812d
3099c4eb-8f5f-4500-a30a-e7fa638ef4f9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9826254b-4208-479f-af75-c59a0d88babb	cc869775-11cb-4a30-a846-79edbe15812d
a35d50e2-37e5-4e74-a8a9-8278e34f620e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a90ec4f0-1377-4ce9-97b6-a379e0a6aa3a	cc869775-11cb-4a30-a846-79edbe15812d
c52ac40c-5218-42c9-ae83-ccaf32abd2f1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d9361d85-2226-44be-b864-ad171091950c	cc869775-11cb-4a30-a846-79edbe15812d
f95026b8-ecec-454c-9010-d2d0516d4bd2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	b104483d-5d55-43fc-8404-e288af93075d	cc869775-11cb-4a30-a846-79edbe15812d
f8173e4f-eb04-4037-87ec-a82b95cb955d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	aac0b568-4f07-4550-9b93-4c7c95c62d27	cc869775-11cb-4a30-a846-79edbe15812d
f457081a-eb53-4e31-9d9d-b6304ac2c48c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	c9bc0f9b-4414-4242-bb3f-ff992ef747e1	cc869775-11cb-4a30-a846-79edbe15812d
5e2c3389-8817-4a2f-b5c5-1448f68f8ce6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5e21829a-b5e3-4498-bb83-e912d258e2b8	cc869775-11cb-4a30-a846-79edbe15812d
85169a20-2cef-4f57-a1de-88c344aa8689	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	53bde808-7662-4bfc-a407-54fd1b83b4f6	cc869775-11cb-4a30-a846-79edbe15812d
953e5bc2-9461-478f-9da9-49fbf52e01f2	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	6aa204fc-9d92-4a1b-8f6a-28fbd326b545	cc869775-11cb-4a30-a846-79edbe15812d
be29aad8-9d33-4055-839f-d28726d504dc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f57329b0-3437-466d-9a90-9c9663075aee	cc869775-11cb-4a30-a846-79edbe15812d
c103b5b8-bace-46bd-a1ec-fdef1031eda0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	470d6e78-cc9b-40a2-b365-25f7b3bba977	cc869775-11cb-4a30-a846-79edbe15812d
fa4b3e2f-6187-4040-9d81-c90393983482	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ac154839-ac39-455f-a2b1-9ba4efbcbbd5	cc869775-11cb-4a30-a846-79edbe15812d
0b6b43c9-f956-4a5d-b526-e32cd6192891	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	ec44affc-f5ff-40ef-a3de-b8f303fee488	cc869775-11cb-4a30-a846-79edbe15812d
91cca2c5-32ea-489f-a74e-147be5590a0b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	53e744ac-828b-41ed-b12a-34f7829c1e38	cc869775-11cb-4a30-a846-79edbe15812d
978ccad7-dca4-4686-a77d-d1b93aa06250	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3a55a2a5-5792-4cac-8d1a-f89f2636b489	cc869775-11cb-4a30-a846-79edbe15812d
511a748b-f69e-40ca-98cd-c2e02ce54a00	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	0018a2fa-7431-421b-b0a6-6fdbd5878622	cc869775-11cb-4a30-a846-79edbe15812d
04b027a4-011c-41b6-9a71-e6f6df20834d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e59de9e0-b09d-40fd-9924-3aba2fb86d7b	cc869775-11cb-4a30-a846-79edbe15812d
45dd75ba-8974-4fd6-bdc2-79fb7db45fe5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	98c7399e-0621-457a-b93b-d8eeaaac4630	cc869775-11cb-4a30-a846-79edbe15812d
5113ff7a-2cda-4f1b-9318-5f8b8312fb45	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9392dfcd-3eb4-428d-ab2f-fa38c0a33c90	cc869775-11cb-4a30-a846-79edbe15812d
94e0d5ab-2653-4492-8915-567345a2b080	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	79cdf8e8-d92d-4dd2-ac25-05633943c332	cc869775-11cb-4a30-a846-79edbe15812d
cfcc6b4f-b27a-4ad2-b92c-db25e7bada02	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	12ad4336-b729-4548-8029-c4282d7fb413	cc869775-11cb-4a30-a846-79edbe15812d
89f40f6f-0222-4364-a633-b2516639f179	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	7d5833ec-4956-437a-a755-b34635b1fb5c	cc869775-11cb-4a30-a846-79edbe15812d
f8c98e1d-3f12-4cc7-a2b0-969cbdfac03b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d0836e66-8c5a-4a56-985e-c04f2bea6fc4	cc869775-11cb-4a30-a846-79edbe15812d
100c87be-2529-4e03-9e56-24374cb7b1b5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	cffd4755-5598-42df-8634-68beb98c13a4	cc869775-11cb-4a30-a846-79edbe15812d
67b97fbc-d645-4513-8b94-07f9ea11d14e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	38d853ee-2655-4675-94c3-32aa7c6710e9	cc869775-11cb-4a30-a846-79edbe15812d
13db89ac-210a-4c28-aca7-3a6dc1ac11fa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	5b91137f-8c0a-403f-8bd3-f26ba765e8a3	cc869775-11cb-4a30-a846-79edbe15812d
a8e22bce-83ff-4ad8-b5f7-822dc7ec4901	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1da9779d-0ee5-4a93-8e48-254e19ea71eb	cc869775-11cb-4a30-a846-79edbe15812d
d437e664-6aba-476b-8f4c-8fc3c1d391ef	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f4c87468-fa82-45fc-aa90-d3668f808a3b	cc869775-11cb-4a30-a846-79edbe15812d
5f9e02d9-2c1d-4e6a-af69-d05f3c48d139	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	676ad3ae-87fa-4a38-8bf7-2debba141c77	cc869775-11cb-4a30-a846-79edbe15812d
a219ed8b-6c12-48d7-b32c-2899c06b93e7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	1ada31fb-2e34-4d71-ac8e-b634e8afcfc6	cc869775-11cb-4a30-a846-79edbe15812d
0bd12742-78b6-46c7-973f-b403a098cc78	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a20f0416-b723-4615-b9dd-644a7cee6f75	cc869775-11cb-4a30-a846-79edbe15812d
c88f96ec-bb45-4fd7-b0a0-e3fdf54748b7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	f8694dbb-a668-4fd2-9e16-0ab2f6c11dac	cc869775-11cb-4a30-a846-79edbe15812d
321bf439-25b4-4b3f-a5a2-e3483d3b0197	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	3b26cf90-2aac-4a1d-ad77-f72dd22614dc	cc869775-11cb-4a30-a846-79edbe15812d
09a6c298-49ba-4f6e-be43-91cace4f3085	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	6daeba48-4cf8-4566-9194-f9bc5dccc134	cc869775-11cb-4a30-a846-79edbe15812d
620a8592-97d3-4a86-a3e2-f6d9e797fe57	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	e4072a3c-cca1-44cf-a465-dcf6281fbcd3	cc869775-11cb-4a30-a846-79edbe15812d
b7281730-82bf-4495-9252-d4b8558a650d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d2d93c15-e9a1-4bd4-bd69-67fd18be74c8	cc869775-11cb-4a30-a846-79edbe15812d
3c06e785-0c59-4a96-9b01-0cd241c6dfab	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d66b699b-9605-4c11-9730-dcb26df0f882	cc869775-11cb-4a30-a846-79edbe15812d
132de63e-67ec-4748-bda8-d50d8c5e7e42	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	cc869775-11cb-4a30-a846-79edbe15812d
5ab5b108-6067-4c9f-b41a-22867d1fd39f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	9fc4ca33-d77a-452f-aa97-677485aa2285	cc869775-11cb-4a30-a846-79edbe15812d
dedcae76-d15c-40c6-b0d7-68627a5a22a7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	bb9480ff-bee6-48a3-bd70-a927f8faa96e	cc869775-11cb-4a30-a846-79edbe15812d
71216404-da00-4b08-95be-2bf2fda1b079	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	61b1fbb4-305b-406d-8906-b48d47be9faf	cc869775-11cb-4a30-a846-79edbe15812d
d5f0ea17-bf83-4eb0-b236-0654eb2daf54	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	d2f073e6-bf79-4937-ad0e-f47dbbf335b7	cc869775-11cb-4a30-a846-79edbe15812d
af3ea1e5-99a6-40de-91e3-338a03f099e3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	4fd836c0-e4b7-4de5-ae7d-57a9d29b7325	cc869775-11cb-4a30-a846-79edbe15812d
6864a332-3122-47f7-aa6a-1f036b50d7ce	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	a3cffb9f-f431-4a96-a29c-bbe01caee891	cc869775-11cb-4a30-a846-79edbe15812d
67337539-29bb-4704-9372-d4d885f2c12b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	95791439-c679-4dec-98cf-1eccedd65a87	cc869775-11cb-4a30-a846-79edbe15812d
3383b24e-9350-434d-a761-d59bffc4b8ee	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:41:57.940934	2025-12-24 12:41:57.940934	11c12969-2713-49e7-aa8a-906f4c9fb1e3	cc869775-11cb-4a30-a846-79edbe15812d
30a35603-813c-457a-85bf-b60236ed075b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:46:07.933048	2025-12-24 12:46:07.933048	d4b193b0-b27a-4630-bab0-034b9e101f16	cc869775-11cb-4a30-a846-79edbe15812d
77c2e3d2-9f44-4173-ba2e-0abea5358403	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:51:21.301841	2025-12-24 12:51:21.301841	f9843d7c-aff4-4c17-9c16-e862b02d4247	cc869775-11cb-4a30-a846-79edbe15812d
e8dd4f1d-0035-4da0-a0f3-37a110b4cde0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:05:26.014838	2025-12-24 13:05:26.014838	909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	08c8a61a-a9eb-489d-a603-dfadcb1e8618
562cfdd5-59bd-45af-ac3f-38125cd58a80	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 13:05:26.025743	2025-12-24 13:05:26.025743	be3cf16a-1466-4065-a1b0-47ff590bc0b4	08c8a61a-a9eb-489d-a603-dfadcb1e8618
c56efa00-60cb-460e-b17f-1d936b5c3b9c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 14:57:56.10318	2025-12-24 14:57:56.10318	f9843d7c-aff4-4c17-9c16-e862b02d4247	70dd98cb-2806-4079-ad98-c4d605611e58
1da4c2c0-b54a-4da6-bfaa-d970f09a326f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:11:25.878234	2025-12-25 00:11:25.878234	b7ebfe37-930b-4c26-bad4-feb829c126fe	cc869775-11cb-4a30-a846-79edbe15812d
64416e9e-dd77-43cc-b179-44a9f6b055a1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:18:21.736904	2025-12-25 00:18:21.736904	baad6e50-b52a-4232-978b-c331c7161203	cc869775-11cb-4a30-a846-79edbe15812d
6005d8ba-bf72-4f28-bc64-1392848bd5aa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:21:10.364056	2025-12-25 00:21:10.364056	83e5f585-bca8-47c4-abb7-02c23289b622	cc869775-11cb-4a30-a846-79edbe15812d
c5c4f6a6-f428-481c-b861-becd5e1ade33	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 08:33:34.924266	2025-12-25 08:33:34.924266	1c682cd5-1951-4105-9a25-90021edb0f9e	cc869775-11cb-4a30-a846-79edbe15812d
4a75f036-22c6-42dd-92b4-923243f4b9e1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:39:30.959776	2025-12-26 16:39:30.959776	d105993f-6f85-4144-ba14-dd361ae6df2e	cc869775-11cb-4a30-a846-79edbe15812d
97464e4a-1680-421a-b6b4-d011c8a4d496	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:41:43.965204	2025-12-26 16:41:43.965204	9bbb842d-accd-43f7-b156-ca8b5b85fd94	cc869775-11cb-4a30-a846-79edbe15812d
56fb380a-ac29-49dc-9dbd-94c20acd1a3d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:15:57.327201	2025-12-26 17:15:57.327201	3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	cc869775-11cb-4a30-a846-79edbe15812d
5cd664bc-e7bf-4736-aea5-4d554e26454e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:41:32.930442	2025-12-26 17:41:32.930442	478839d7-1cf2-4780-99ec-a89f08466f8f	cc869775-11cb-4a30-a846-79edbe15812d
1595dfb2-9c67-45dc-872c-22d0c84dfaa1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:11:33.222361	2025-12-26 18:11:33.222361	a281a08d-571e-4e7d-87a7-50c0e990fc52	cc869775-11cb-4a30-a846-79edbe15812d
a03eb57c-e453-44d4-a648-7342220e822f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 17:25:30.240851	2025-12-30 17:25:30.240851	44142ebb-779d-4e83-b0a2-3db691e389ff	7a712638-c3cf-47e3-9bd2-43312f93a669
\.


--
-- TOC entry 4401 (class 0 OID 66042)
-- Dependencies: 239
-- Data for Name: user_villas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_villas (id, company_id, user_id, villa_id, created_at) FROM stdin;
92c2a561-777b-42e2-b295-1031dcef6c32	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	b2538e1f-506a-482c-9c24-0de06815f08c	2025-12-23 15:37:55.462867+05:30
df0f18b4-063e-488d-b86d-c6cad8717191	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	7e443cc8-bca1-45a1-a646-c3284395f237	2025-12-23 15:37:55.462867+05:30
5c7a77d3-9285-40b2-a5b6-cc8dcd6f01a1	eb75a65b-055f-4408-a58c-71d233443c17	95791439-c679-4dec-98cf-1eccedd65a87	77e652f1-70da-4a61-8190-492134544c80	2025-12-23 15:37:55.462867+05:30
\.


--
-- TOC entry 4387 (class 0 OID 65601)
-- Dependencies: 225
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, company_id, created_at, updated_at, email, "passwordHash", "firstName", "lastName", department_id, status, "authProvider", external_id, "providerMetadata", last_login_at, phone_number, alternate_phone_number, lease_expiry_date, deleted_at, villa_number, villa_numbers) FROM stdin;
d105993f-6f85-4144-ba14-dd361ae6df2e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:39:30.947779	2025-12-26 17:02:26.022503	elavarsan@helixsense.com	$2b$10$TyCZeLyp8KlAFzH5pOo/5u10o.pksMAfQbZfAX/livZxvmvCJASSK	Elavarsan	V	\N	active	local	\N	\N	2025-12-26 17:02:26.022	\N	\N	\N	\N	A-275	["A-275"]
a281a08d-571e-4e7d-87a7-50c0e990fc52	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:11:33.213486	2025-12-26 18:11:33.213486	prassanna@helixsense.com	$2b$10$1SoRC6KORqt4ec3PVPvIj.NEv1YwK5YYeZmQsMTcMmQ6oMw6dWxDK	Prasanna	John	\N	active	local	\N	\N	\N	\N	\N	\N	\N	A-2745	["A-2745"]
909cb1f0-ec3d-4218-b2ff-96bac44e5bb0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-26 18:21:22.53374	technician1@villa-maintenance.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	John	Technician	\N	active	local	\N	\N	2025-12-26 18:21:22.533	\N	\N	\N	\N	\N	\N
be3cf16a-1466-4065-a1b0-47ff590bc0b4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-26 10:49:36.252659	technician2@villa-maintenance.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Jane	Technician	\N	active	local	\N	\N	2025-12-26 10:49:36.252	\N	\N	\N	\N	\N	\N
26fb3c7e-5d31-490e-8f69-a96c53c96bcc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa2@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	2	\N	active	local	\N	\N	\N	\N	\N	\N	\N	2	\N
bfa1c651-6d51-417f-a8bd-2130dd3bc28c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-26 12:33:56.797814	coordinator@villa-maintenance.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Site	Coordinator	\N	active	local	\N	\N	2025-12-26 12:33:56.796	\N	\N	\N	\N	\N	\N
4ecb4192-9e6a-410d-9cc5-7037a5a104eb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-26 12:34:13.490559	supervisor@villa-maintenance.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Maintenance	Supervisor	\N	active	local	\N	\N	2025-12-26 12:34:13.489	\N	\N	\N	\N	\N	\N
9bbb842d-accd-43f7-b156-ca8b5b85fd94	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:41:43.956827	2025-12-26 16:41:43.956827	boscoitsmobile@gmail.com	$2b$10$q5xDbnz/pRyUsbaFSabvpOuCr3Ie/cXRVfrxSvjT7wOkfJCe7JMpO	Surya 	Ellappan	\N	active	local	\N	\N	\N	\N	\N	\N	\N	A-5660	["A-5660"]
bb9480ff-bee6-48a3-bd70-a927f8faa96e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa81@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	81	\N	active	local	\N	\N	\N	\N	\N	\N	\N	81	\N
61b1fbb4-305b-406d-8906-b48d47be9faf	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa82@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	82	\N	active	local	\N	\N	\N	\N	\N	\N	\N	82	\N
d2f073e6-bf79-4937-ad0e-f47dbbf335b7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa83@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	83	\N	active	local	\N	\N	\N	\N	\N	\N	\N	83	\N
4fd836c0-e4b7-4de5-ae7d-57a9d29b7325	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa84@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	84	\N	active	local	\N	\N	\N	\N	\N	\N	\N	84	\N
a3cffb9f-f431-4a96-a29c-bbe01caee891	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa85@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	85	\N	active	local	\N	\N	\N	\N	\N	\N	\N	85	\N
5fb6cc19-15bc-43c0-82ad-5a55f3ddf1db	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa3@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	3	\N	active	local	\N	\N	\N	\N	\N	\N	\N	3	\N
b1469661-e285-4513-ac3d-fffcc131daa6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa4@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	4	\N	active	local	\N	\N	\N	\N	\N	\N	\N	4	\N
be7c2045-9191-4083-86c2-383c166520bc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa5@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	5	\N	active	local	\N	\N	\N	\N	\N	\N	\N	5	\N
aa1a0cdc-8202-4654-a28e-9bda086a3f84	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa6@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	6	\N	active	local	\N	\N	\N	\N	\N	\N	\N	6	\N
2c4ad4f5-3790-4cba-b383-bab4e583109f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa7@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	7	\N	active	local	\N	\N	\N	\N	\N	\N	\N	7	\N
71e291b7-f092-40b6-9819-8fc848682e6a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa8@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	8	\N	active	local	\N	\N	\N	\N	\N	\N	\N	8	\N
390bd96a-c854-416d-8660-802e754dfe30	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa9@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	9	\N	active	local	\N	\N	\N	\N	\N	\N	\N	9	\N
0eb03419-5169-4605-a380-679a5d9faf95	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa10@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	10	\N	active	local	\N	\N	\N	\N	\N	\N	\N	10	\N
b7ebfe37-930b-4c26-bad4-feb829c126fe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:11:25.871713	2025-12-25 00:11:25.871713	vivekvalliott@gmail.com	$2b$10$XhecRmqjnXiVelfBhKe9puw29PXK2lgqz.k8LwbO3ZdofSPSTScEy	Vivek E	Ellapapan	\N	active	local	\N	\N	\N	\N	\N	\N	\N	\N	\N
d1c5678e-bd8c-4db0-a303-020d49396e0f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa11@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	11	\N	active	local	\N	\N	\N	\N	\N	\N	\N	11	\N
071618e8-48df-4397-bf58-13500b13b963	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa12@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	12	\N	active	local	\N	\N	\N	\N	\N	\N	\N	12	\N
d4b193b0-b27a-4630-bab0-034b9e101f16	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:46:07.925301	2025-12-24 15:17:45.994305	vivek2@test.com	$2b$10$bWzQViPrZWYONm7cJKSyoeOF2.my95Jie2WgOnIoFTH2nIqhfcOm6	Vivek Ellappan	E	\N	inactive	local	\N	\N	\N	\N	\N	\N	\N	\N	\N
11c12969-2713-49e7-aa8a-906f4c9fb1e3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:41:57.931581	2025-12-24 15:22:43.014185	vivek@test.com	$2b$10$Md3OYV2xb1Yrm5lE7NX8se8qwbQiAGB65CzfVJIvYHc9QGHNz70t.	Vivek	E	\N	inactive	local	\N	\N	\N	\N	\N	\N	\N	\N	\N
5ae848af-e1e2-4dc3-a14d-c8a5396b824e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa13@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	13	\N	active	local	\N	\N	\N	\N	\N	\N	\N	13	\N
ccdaf2d6-3905-4d04-b7a9-c6ac5c3ac2d0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa14@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	14	\N	active	local	\N	\N	\N	\N	\N	\N	\N	14	\N
f008eb79-35b9-4af7-95f3-0c136cb32b13	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa15@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	15	\N	active	local	\N	\N	\N	\N	\N	\N	\N	15	\N
8eb63fe5-7d76-48a0-9456-36d698f469ed	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa16@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	16	\N	active	local	\N	\N	\N	\N	\N	\N	\N	16	\N
9bd4b184-458f-4eab-9472-6578042407e0	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa17@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	17	\N	active	local	\N	\N	\N	\N	\N	\N	\N	17	\N
3eed5386-cd3b-4312-85df-bc01d2f385a6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa18@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	18	\N	active	local	\N	\N	\N	\N	\N	\N	\N	18	\N
8bcb8775-4b58-4050-85f8-885a9b8b0fe4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa19@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	19	\N	active	local	\N	\N	\N	\N	\N	\N	\N	19	\N
b4968123-7908-457a-9e7c-2ae17c8fadaa	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa20@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	20	\N	active	local	\N	\N	\N	\N	\N	\N	\N	20	\N
60803f2d-364d-4286-8fdc-8248485b9b82	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa21@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	21	\N	active	local	\N	\N	\N	\N	\N	\N	\N	21	\N
407f8619-e786-4515-8bbe-1676e3bbc361	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa22@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	22	\N	active	local	\N	\N	\N	\N	\N	\N	\N	22	\N
398a1e8a-ff59-49d9-a52f-86d0270964ff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa23@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	23	\N	active	local	\N	\N	\N	\N	\N	\N	\N	23	\N
457cc731-4a14-462c-bba5-c0a67fe2b0e4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa24@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	24	\N	active	local	\N	\N	\N	\N	\N	\N	\N	24	\N
fd842408-0197-42b3-b459-d674809b1276	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa25@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	25	\N	active	local	\N	\N	\N	\N	\N	\N	\N	25	\N
15524c37-d38a-415f-b2d9-1f5eecbbdee8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa26@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	26	\N	active	local	\N	\N	\N	\N	\N	\N	\N	26	\N
b18189ca-de52-4473-abc4-4e019eb74fef	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa27@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	27	\N	active	local	\N	\N	\N	\N	\N	\N	\N	27	\N
2882fe7b-13dd-4184-94da-d8b80c2a06c7	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa28@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	28	\N	active	local	\N	\N	\N	\N	\N	\N	\N	28	\N
d06fa247-c417-4f2e-9563-0adf28a21f44	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa29@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	29	\N	active	local	\N	\N	\N	\N	\N	\N	\N	29	\N
148547a8-d99f-4fb4-bb01-5bb7c6f2b159	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa30@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	30	\N	active	local	\N	\N	\N	\N	\N	\N	\N	30	\N
cfb8af0f-11c6-464b-8e84-747f9cbdcb84	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa31@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	31	\N	active	local	\N	\N	\N	\N	\N	\N	\N	31	\N
03b5e215-5057-405c-9ba4-a3485b1d0c89	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa32@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	32	\N	active	local	\N	\N	\N	\N	\N	\N	\N	32	\N
f8a34b8b-b250-4c8d-b45a-a09522f0b34b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa33@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	33	\N	active	local	\N	\N	\N	\N	\N	\N	\N	33	\N
42264350-62a4-4119-b213-4e2f68ebe513	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa34@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	34	\N	active	local	\N	\N	\N	\N	\N	\N	\N	34	\N
61e3614b-3b90-47a9-baf7-ecf8e7a6b96c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa35@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	35	\N	active	local	\N	\N	\N	\N	\N	\N	\N	35	\N
2df7ef09-1682-43c9-9c64-e479c86c1c1e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa36@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	36	\N	active	local	\N	\N	\N	\N	\N	\N	\N	36	\N
4cb39fa4-be14-4a89-9fae-f88ea5406111	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa37@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	37	\N	active	local	\N	\N	\N	\N	\N	\N	\N	37	\N
120785d1-cb13-4721-9ef9-0bf3ab8f860f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa38@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	38	\N	active	local	\N	\N	\N	\N	\N	\N	\N	38	\N
38a4ff0d-a3ad-4c48-b4e1-02706892b17d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa39@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	39	\N	active	local	\N	\N	\N	\N	\N	\N	\N	39	\N
d4c313e9-9190-43d3-9280-4e19a3619f44	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa40@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	40	\N	active	local	\N	\N	\N	\N	\N	\N	\N	40	\N
93d899ce-d497-4f95-82b2-fe293db75dc5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa41@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	41	\N	active	local	\N	\N	\N	\N	\N	\N	\N	41	\N
9826254b-4208-479f-af75-c59a0d88babb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa42@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	42	\N	active	local	\N	\N	\N	\N	\N	\N	\N	42	\N
a90ec4f0-1377-4ce9-97b6-a379e0a6aa3a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa43@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	43	\N	active	local	\N	\N	\N	\N	\N	\N	\N	43	\N
d9361d85-2226-44be-b864-ad171091950c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa44@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	44	\N	active	local	\N	\N	\N	\N	\N	\N	\N	44	\N
b104483d-5d55-43fc-8404-e288af93075d	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa45@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	45	\N	active	local	\N	\N	\N	\N	\N	\N	\N	45	\N
aac0b568-4f07-4550-9b93-4c7c95c62d27	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa46@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	46	\N	active	local	\N	\N	\N	\N	\N	\N	\N	46	\N
c9bc0f9b-4414-4242-bb3f-ff992ef747e1	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa47@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	47	\N	active	local	\N	\N	\N	\N	\N	\N	\N	47	\N
5e21829a-b5e3-4498-bb83-e912d258e2b8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa48@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	48	\N	active	local	\N	\N	\N	\N	\N	\N	\N	48	\N
53bde808-7662-4bfc-a407-54fd1b83b4f6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa49@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	49	\N	active	local	\N	\N	\N	\N	\N	\N	\N	49	\N
6aa204fc-9d92-4a1b-8f6a-28fbd326b545	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa50@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	50	\N	active	local	\N	\N	\N	\N	\N	\N	\N	50	\N
f57329b0-3437-466d-9a90-9c9663075aee	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa51@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	51	\N	active	local	\N	\N	\N	\N	\N	\N	\N	51	\N
470d6e78-cc9b-40a2-b365-25f7b3bba977	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa52@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	52	\N	active	local	\N	\N	\N	\N	\N	\N	\N	52	\N
ac154839-ac39-455f-a2b1-9ba4efbcbbd5	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa53@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	53	\N	active	local	\N	\N	\N	\N	\N	\N	\N	53	\N
ec44affc-f5ff-40ef-a3de-b8f303fee488	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa54@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	54	\N	active	local	\N	\N	\N	\N	\N	\N	\N	54	\N
53e744ac-828b-41ed-b12a-34f7829c1e38	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa55@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	55	\N	active	local	\N	\N	\N	\N	\N	\N	\N	55	\N
3a55a2a5-5792-4cac-8d1a-f89f2636b489	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa56@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	56	\N	active	local	\N	\N	\N	\N	\N	\N	\N	56	\N
0018a2fa-7431-421b-b0a6-6fdbd5878622	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa57@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	57	\N	active	local	\N	\N	\N	\N	\N	\N	\N	57	\N
e59de9e0-b09d-40fd-9924-3aba2fb86d7b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa58@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	58	\N	active	local	\N	\N	\N	\N	\N	\N	\N	58	\N
98c7399e-0621-457a-b93b-d8eeaaac4630	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa59@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	59	\N	active	local	\N	\N	\N	\N	\N	\N	\N	59	\N
9392dfcd-3eb4-428d-ab2f-fa38c0a33c90	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa60@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	60	\N	active	local	\N	\N	\N	\N	\N	\N	\N	60	\N
79cdf8e8-d92d-4dd2-ac25-05633943c332	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa61@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	61	\N	active	local	\N	\N	\N	\N	\N	\N	\N	61	\N
12ad4336-b729-4548-8029-c4282d7fb413	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa62@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	62	\N	active	local	\N	\N	\N	\N	\N	\N	\N	62	\N
7d5833ec-4956-437a-a755-b34635b1fb5c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa63@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	63	\N	active	local	\N	\N	\N	\N	\N	\N	\N	63	\N
d0836e66-8c5a-4a56-985e-c04f2bea6fc4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa64@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	64	\N	active	local	\N	\N	\N	\N	\N	\N	\N	64	\N
cffd4755-5598-42df-8634-68beb98c13a4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa65@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	65	\N	active	local	\N	\N	\N	\N	\N	\N	\N	65	\N
38d853ee-2655-4675-94c3-32aa7c6710e9	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa66@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	66	\N	active	local	\N	\N	\N	\N	\N	\N	\N	66	\N
5b91137f-8c0a-403f-8bd3-f26ba765e8a3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa67@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	67	\N	active	local	\N	\N	\N	\N	\N	\N	\N	67	\N
1da9779d-0ee5-4a93-8e48-254e19ea71eb	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa68@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	68	\N	active	local	\N	\N	\N	\N	\N	\N	\N	68	\N
f4c87468-fa82-45fc-aa90-d3668f808a3b	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa69@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	69	\N	active	local	\N	\N	\N	\N	\N	\N	\N	69	\N
676ad3ae-87fa-4a38-8bf7-2debba141c77	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa70@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	70	\N	active	local	\N	\N	\N	\N	\N	\N	\N	70	\N
1ada31fb-2e34-4d71-ac8e-b634e8afcfc6	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa71@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	71	\N	active	local	\N	\N	\N	\N	\N	\N	\N	71	\N
a20f0416-b723-4615-b9dd-644a7cee6f75	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa72@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	72	\N	active	local	\N	\N	\N	\N	\N	\N	\N	72	\N
f8694dbb-a668-4fd2-9e16-0ab2f6c11dac	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa73@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	73	\N	active	local	\N	\N	\N	\N	\N	\N	\N	73	\N
3b26cf90-2aac-4a1d-ad77-f72dd22614dc	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa74@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	74	\N	active	local	\N	\N	\N	\N	\N	\N	\N	74	\N
6daeba48-4cf8-4566-9194-f9bc5dccc134	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa75@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	75	\N	active	local	\N	\N	\N	\N	\N	\N	\N	75	\N
e4072a3c-cca1-44cf-a465-dcf6281fbcd3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa76@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	76	\N	active	local	\N	\N	\N	\N	\N	\N	\N	76	\N
d2d93c15-e9a1-4bd4-bd69-67fd18be74c8	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa77@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	77	\N	active	local	\N	\N	\N	\N	\N	\N	\N	77	\N
d66b699b-9605-4c11-9730-dcb26df0f882	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa78@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	78	\N	active	local	\N	\N	\N	\N	\N	\N	\N	78	\N
73ae5f6c-d089-4500-b9f1-5b92dd65ebf4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa79@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	79	\N	active	local	\N	\N	\N	\N	\N	\N	\N	79	\N
9fc4ca33-d77a-452f-aa97-677485aa2285	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-23 15:17:30.673953	villa80@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	80	\N	active	local	\N	\N	\N	\N	\N	\N	\N	80	\N
f9843d7c-aff4-4c17-9c16-e862b02d4247	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 12:51:21.293997	2025-12-24 23:22:51.379633	vivek3@gmail.com	$2b$10$8fCRfrhCcd21Sei9zB7Ikua44P6AF37QXH2e0Nm5FIzl7BGnbrM6e	Vivek 	Vivek	\N	active	local	\N	\N	\N	\N	\N	\N	\N	100	["100"]
baad6e50-b52a-4232-978b-c331c7161203	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:18:21.727506	2025-12-25 00:18:21.727506	ellappanvivek@gmaill.com	$2b$10$vn3EUAIXf50vEtyrQfIKjeXVwlVGNbEYdemg363STMaD.OglOvqbC	Vivek Ellappan	E	\N	active	local	\N	\N	\N	\N	\N	\N	\N	1111	["1111"]
83e5f585-bca8-47c4-abb7-02c23289b622	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:21:10.355928	2025-12-25 00:21:10.355928	ellappanvivek@gmail.com	$2b$10$Q8ZUPOkTTePvfokiduTHYu6IPev3kMDFxByYNuGVarzB8HTmZi53e	ellappanvivek	ellappanvivek	\N	active	local	\N	\N	\N	\N	\N	\N	\N	10122	["10122"]
1c682cd5-1951-4105-9a25-90021edb0f9e	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 08:33:34.914477	2025-12-25 08:33:34.914477	mayaon@test.com	$2b$10$B579iE9cq0BYn2hE6BJiFO3s5BFfseIR.9PJ92peMWIGrqk/4S1lK	Mayaon	S	\N	active	local	\N	{"notes": "Yes"}	\N	\N	\N	\N	\N	501	["501"]
478839d7-1cf2-4780-99ec-a89f08466f8f	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:41:32.921158	2025-12-26 17:41:32.921158	prasaugs@gmail.com	$2b$10$KJ0IwcW6OeT4t2B5/zp2jOy8k8JRreJikNmsz6vpOyRw.oieO0slW	Prasanna	John	\N	active	local	\N	\N	\N	\N	\N	\N	\N	A-202	["A-202"]
44142ebb-779d-4e83-b0a2-3db691e389ff	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:37:44.711994	2026-01-01 12:49:52.226505	vivek.ellappan@helixsense.com	$2b$10$M/LJIS.C6gJ/63FGylMGPuvQmu9aDAum15jssXXsp1t8nBRq/QUfm	Vivek	Ellappan	\N	active	local	\N	{"notes": "For Villa 5011"}	2026-01-01 12:49:52.225	\N	\N	\N	\N	5011	["5011"]
1d97134a-1b6a-47da-b3da-9324aa1a2f69	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-30 12:42:15.557087	villa1@tenant.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	Villa	1	\N	inactive	local	\N	\N	2025-12-30 12:42:15.556	\N	\N	\N	\N	1	\N
3866c51f-a5db-47c4-a4ef-c2ed75eec7f4	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:15:57.319132	2025-12-30 12:43:54.961508	vaibhav.b@helixsense.com	$2b$10$uOQ9ek8Lajq.yD3acM7uCOryHCd3gtRH12j2AgIM/QTOoRIe8ip5.	Vivek	E	\N	active	local	\N	\N	2025-12-30 12:43:54.96	\N	\N	\N	\N	A-324	["A-324"]
3b1f6b73-cc02-4627-ae83-8e1ebc5616ec	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2025-12-30 17:25:30.240851	admin@villa-maintenance.com	$2b$10$QRZt3q3TUt7eb7rcdVEGo.EcdVDfOJo9VwDWoCdMq5d02TIsai77G	System	Administrator	\N	active	local	\N	\N	2025-12-30 12:34:57.764	\N	\N	\N	2025-12-30 17:25:30.240851	\N	\N
95791439-c679-4dec-98cf-1eccedd65a87	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:17:30.673953	2026-01-01 07:56:29.774154	vivekebiit@gmail.com	$2b$10$ylQKpu/RDGWSf0q2/skvaOXnJ82nRuyRP..Jw3GvK4SH3H.RDw7fW	Vivek	Ellappan	\N	active	local	\N	\N	2026-01-01 07:56:29.773	9345281193	\N	\N	\N	86	\N
\.


--
-- TOC entry 4404 (class 0 OID 66586)
-- Dependencies: 242
-- Data for Name: villa_type_configs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.villa_type_configs (id, company_id, villa_type, display_name, default_bedroom_count, default_floor_count, default_area_sqm, display_order, is_active, metadata, created_at, updated_at) FROM stdin;
5908ca35-c5d9-441b-ba2a-82e07601d805	eb75a65b-055f-4408-a58c-71d233443c17	Studio	Studio Apartment	1	1	35.00	0	t	\N	2025-12-30 11:45:19.759337+05:30	2025-12-30 12:10:40.994392+05:30
429164ac-c529-4b16-ac0a-789556e121bf	eb75a65b-055f-4408-a58c-71d233443c17	1BHK	1 Bedroom Hall Kitchen	1	1	60.00	1	t	\N	2025-12-30 11:45:19.759337+05:30	2025-12-30 12:10:40.998684+05:30
69695631-4a9f-4496-a68d-a7d0818812b6	eb75a65b-055f-4408-a58c-71d233443c17	2BHK	2 Bedroom Hall Kitchen	2	1	95.00	2	t	\N	2025-12-30 11:45:19.759337+05:30	2025-12-30 12:10:40.99919+05:30
eae9639d-8776-451f-b4e4-cdbeac03851d	eb75a65b-055f-4408-a58c-71d233443c17	3BHK	3 Bedroom Hall Kitchen	3	1	140.00	3	t	\N	2025-12-30 11:45:19.759337+05:30	2025-12-30 12:10:40.99957+05:30
94f2aeaf-1eda-47ad-9f12-038026a7cbda	eb75a65b-055f-4408-a58c-71d233443c17	4BHK	4 Bedroom Hall Kitchen	4	1	200.00	4	t	\N	2025-12-30 11:45:19.759337+05:30	2025-12-30 12:10:40.99989+05:30
815f2c16-0bee-4685-bb36-c3a6de04017b	eb75a65b-055f-4408-a58c-71d233443c17	5BHK	5 Bedroom Hall Kitchen	5	1	275.00	5	t	\N	2025-12-30 12:10:04.478961+05:30	2025-12-30 12:10:41.000195+05:30
cd7ced18-dde5-4ced-be00-009677c682db	eb75a65b-055f-4408-a58c-71d233443c17	Penthouse	Penthouse	\N	1	300.00	6	t	\N	2025-12-30 11:45:19.759337+05:30	2025-12-30 12:10:41.000482+05:30
63b7ca53-0353-4a97-95f4-ace3a08ae49c	eb75a65b-055f-4408-a58c-71d233443c17	Duplex	Duplex Villa	\N	2	200.00	7	t	\N	2025-12-30 11:45:19.759337+05:30	2025-12-30 12:10:41.000784+05:30
9275f01b-0817-4dee-b945-f24e51ff99b8	eb75a65b-055f-4408-a58c-71d233443c17	Townhouse	Townhouse	\N	2	200.00	8	t	\N	2025-12-30 12:10:04.478961+05:30	2025-12-30 12:10:41.001051+05:30
1a415344-7163-4213-b0b7-8fcc5667f002	eb75a65b-055f-4408-a58c-71d233443c17	Villa	Independent Villa	\N	\N	\N	9	t	\N	2025-12-30 11:45:19.759337+05:30	2025-12-30 12:10:41.00136+05:30
28ab524f-80f2-4e68-98e6-73147fac55a9	eb75a65b-055f-4408-a58c-71d233443c17	Mansion	Mansion	\N	\N	450.00	10	t	\N	2025-12-30 12:10:04.478961+05:30	2025-12-30 12:10:41.001699+05:30
\.


--
-- TOC entry 4376 (class 0 OID 65464)
-- Dependencies: 214
-- Data for Name: villas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.villas (id, company_id, created_at, updated_at, villa_code, site_id, space_id, owner_name, tenant_name, contact_phone, contact_email, block, street, is_active, is_occupied, floor_count, bedroom_count, area_sqm, metadata, villa_type, parking_slot_number, meter_number, water_meter_number, remarks, city, pin_code, villa_number, makani_number, po_box) FROM stdin;
7e443cc8-bca1-45a1-a646-c3284395f237	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:37:55.495869	2025-12-23 15:37:55.495869	V85	\N	\N	\N	\N	\N	\N	\N	\N	t	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	85	\N	\N
77e652f1-70da-4a61-8190-492134544c80	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:37:55.497658	2025-12-23 15:37:55.497658	V86	\N	\N	\N	\N	\N	\N	\N	\N	t	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	86	\N	\N
b2538e1f-506a-482c-9c24-0de06815f08c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-23 15:37:55.481157	2025-12-24 16:45:51.792414	V84	\N	\N	\N	\N	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	84	\N	\N
4433d234-f511-4c55-926d-c6c68103df5c	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 23:18:47.508409	2025-12-24 23:18:47.508409	100	\N	\N	Vivek	Vivek Ellapan	9345271193	vivek@test.com	1	SAI GANESH NAGAR	t	f	1	3	2000.00	\N	\N	\N	\N	\N	\N	\N	\N	100	\N	\N
612c62cf-53bd-4f96-93f0-e7975015ba77	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 23:25:41.883591	2025-12-24 23:25:41.883591	1111	\N	\N	Vivek	Vivek Ellappan E	9345281192	vivek@gamil.com	1	1	t	f	1	1	1.00	\N	\N	\N	\N	\N	\N	\N	\N	1111	\N	\N
da326c95-512e-483b-9030-f2c6ffb5a653	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 00:20:42.506714	2025-12-25 00:20:42.506714	12	\N	\N	12	\N	1	ellappanvivek@gmail.com	1	1	t	f	1	2	22.00	\N	\N	\N	\N	\N	\N	\N	\N	10122	\N	\N
9eafecb5-0d5a-4289-b412-16bef7ed1507	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 07:44:48.388925	2025-12-25 07:44:48.388925	\N	\N	\N	Vivek	\N	9345281193	ellappan@test.com	A	SAI Ganesh	t	t	3	3	1000.00	\N	2BK	121	121	121	ZONE	\N	\N	274	\N	\N
f686bc11-fc8c-41c5-a4cd-4a574709acf3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-25 08:32:31.329809	2025-12-25 08:32:31.329809	\N	\N	\N	Surya	\N	9345281193	test@test.com	2B	SAI Ganesh	t	f	2	2	200.00	\N	2BK	2B	211B	121B	Notes	\N	\N	501	\N	\N
10201ea9-edcd-439b-8640-16944112e963	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-24 23:34:36.218143	2025-12-25 08:45:42.181243	1	\N	\N	1	Vivek Ellappan E	1	1@tmai.com	1	1	f	f	1	1	1.00	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N
d6ef94aa-c596-4d39-9a2b-e12f69f41358	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 10:30:07.941213	2025-12-26 10:30:07.941213	\N	\N	\N	Vivek	\N	9345281193	vivek.ellappan@helixsense.com	2	Anna Nagar	t	f	3	3	2000.00	\N	2BHK	501-1	901	902	Vivek - Chennai 	\N	\N	5011	\N	\N
a8f933e3-de7a-4865-a46a-60860f9794b3	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 12:26:33.035793	2025-12-26 12:26:33.035793	\N	\N	\N	Ela	\N	9345281193	elashc.ela3@gmail.com	ZONE-A-1	Al Osool Group P. O. Box 612 , Hay Al Mina, P.C. 114, Sultanate of Oman	t	f	1	2	100.00	\N	3BK	1	1	1	Remarks	\N	\N	ALOS-101	\N	\N
6fa2296e-7022-4f8b-a775-1024d22d7877	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:35:07.467558	2025-12-26 16:35:07.467558	\N	\N	\N	Elavarasn	\N	9345281193	elashc.ela3@gmail.com	A	Al Osool Group P. O. Box 612 , Hay Al Mina, P.C. 114, Sultanate of Oman	t	f	2	4	2000.00	\N	3BHK	1	987654321	121	\N	Oman	600073	A-275	\N	\N
361ceb32-484c-47eb-b116-c71b82d21ebe	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 16:40:50.382089	2025-12-26 16:40:50.382089	\N	\N	\N	Surya	\N	9345281193	vivekebiit@gmail.com	B	B	t	f	4	4	3000.00	\N	1BHK	121	12345	1234	\N	B	600076	A-5660	\N	\N
8175bb1f-97f6-44eb-a5f6-4d0935cbbf39	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:11:08.425198	2025-12-26 17:11:08.425198	\N	\N	\N	Vivek Ellappan	\N	9345281193	vivekebiit@gmail.com	A	First Main Road	t	f	2	4	2500.00	\N	3BHK	1	121	12345	\N	Chennai	600073	A-324	\N	\N
a407f8a5-44cd-4112-8b30-e23a090c78fd	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 17:39:37.089511	2025-12-26 17:39:37.089511	\N	\N	\N	Vivek	\N	9345281193	vivekebiit@gmail.com	B	S	t	f	2	2	1000.00	\N	3BHK	121	121	121	\N	C	600012	A-202	\N	\N
764c57c1-4d86-44fe-90f0-1261494300af	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-26 18:09:44.540193	2025-12-26 18:09:44.540193	\N	\N	\N	Vivek	\N	9345281194	vaibhav.b@helixsense.com	A	First Main Road 	t	f	1	3	1500.00	\N	3BHK	4567	54321	121	\N	Chennai	600073	A-2745	\N	\N
05c9ed7a-1743-4908-84db-49830cc3080a	eb75a65b-055f-4408-a58c-71d233443c17	2025-12-30 12:38:19.856444	2025-12-30 12:38:19.856444	\N	\N	\N	Vivek	\N	9345281193	vivekebiit@gmail.com	A	Al Reem Island	t	f	1	3	140.00	\N	3BHK	\N	\N	\N	\N	Abu Dhabi	\N	149	1234567890	121
\.


--
-- TOC entry 4100 (class 2606 OID 65802)
-- Name: audit_logs PK_1bb179d048bbc581caa3b013439; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "PK_1bb179d048bbc581caa3b013439" PRIMARY KEY (id);


--
-- TOC entry 3950 (class 2606 OID 65475)
-- Name: villas PK_1e8ef3740bc60f246e518685a6c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.villas
    ADD CONSTRAINT "PK_1e8ef3740bc60f246e518685a6c" PRIMARY KEY (id);


--
-- TOC entry 4087 (class 2606 OID 65773)
-- Name: ticket_sla PK_25e8724497a9414271fa111d2d8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_sla
    ADD CONSTRAINT "PK_25e8724497a9414271fa111d2d8" PRIMARY KEY (id);


--
-- TOC entry 3966 (class 2606 OID 65526)
-- Name: notification_audit_logs PK_34a124f125415f6e312abaeb80e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_audit_logs
    ADD CONSTRAINT "PK_34a124f125415f6e312abaeb80e" PRIMARY KEY (id);


--
-- TOC entry 4091 (class 2606 OID 65789)
-- Name: holidays PK_3646bdd4c3817d954d830881dfe; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT "PK_3646bdd4c3817d954d830881dfe" PRIMARY KEY (id);


--
-- TOC entry 3929 (class 2606 OID 65434)
-- Name: sites PK_4f5eccb1dfde10c9170502595a7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT "PK_4f5eccb1dfde10c9170502595a7" PRIMARY KEY (id);


--
-- TOC entry 4104 (class 2606 OID 65817)
-- Name: hierarchy_nodes PK_64999bed2ab7283bd466cb4e563; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hierarchy_nodes
    ADD CONSTRAINT "PK_64999bed2ab7283bd466cb4e563" PRIMARY KEY (id);


--
-- TOC entry 4060 (class 2606 OID 65718)
-- Name: maintenance_tickets PK_6864618af429f4de6b8aede5afa; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "PK_6864618af429f4de6b8aede5afa" PRIMARY KEY (id);


--
-- TOC entry 3959 (class 2606 OID 65504)
-- Name: notifications PK_6a72c3c0f683f6462415e653c3a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "PK_6a72c3c0f683f6462415e653c3a" PRIMARY KEY (id);


--
-- TOC entry 4029 (class 2606 OID 65671)
-- Name: ticket_categories PK_6e0ee8248a3915067d3f4b64b10; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_categories
    ADD CONSTRAINT "PK_6e0ee8248a3915067d3f4b64b10" PRIMARY KEY (id);


--
-- TOC entry 3963 (class 2606 OID 65515)
-- Name: notification_templates PK_76f0fc48b8d057d2ae7f3a2848a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_templates
    ADD CONSTRAINT "PK_76f0fc48b8d057d2ae7f3a2848a" PRIMARY KEY (id);


--
-- TOC entry 3970 (class 2606 OID 65537)
-- Name: refresh_tokens PK_7d8bee0204106019488c4c50ffa; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "PK_7d8bee0204106019488c4c50ffa" PRIMARY KEY (id);


--
-- TOC entry 4018 (class 2606 OID 65644)
-- Name: ticket_attachments PK_7e5011f87f95e78fe4bd7d982a3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_attachments
    ADD CONSTRAINT "PK_7e5011f87f95e78fe4bd7d982a3" PRIMARY KEY (id);


--
-- TOC entry 4042 (class 2606 OID 65699)
-- Name: teams PK_7e5523774a38b08a6236d322403; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT "PK_7e5523774a38b08a6236d322403" PRIMARY KEY (id);


--
-- TOC entry 4010 (class 2606 OID 65628)
-- Name: ticket_comments PK_811ed3b81dd8df6b9a92058d89c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_comments
    ADD CONSTRAINT "PK_811ed3b81dd8df6b9a92058d89c" PRIMARY KEY (id);


--
-- TOC entry 3955 (class 2606 OID 65491)
-- Name: notification_deliveries PK_81daeff81f237bd384f7cfc4a4c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_deliveries
    ADD CONSTRAINT "PK_81daeff81f237bd384f7cfc4a4c" PRIMARY KEY (id);


--
-- TOC entry 4024 (class 2606 OID 65658)
-- Name: departments PK_839517a681a86bb84cbcc6a1e9d; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT "PK_839517a681a86bb84cbcc6a1e9d" PRIMARY KEY (id);


--
-- TOC entry 3978 (class 2606 OID 65559)
-- Name: role_permissions PK_84059017c90bfcb701b8fa42297; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT "PK_84059017c90bfcb701b8fa42297" PRIMARY KEY (id);


--
-- TOC entry 3996 (class 2606 OID 65598)
-- Name: acl_entries PK_8ab66a564470696e3d75c430d69; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acl_entries
    ADD CONSTRAINT "PK_8ab66a564470696e3d75c430d69" PRIMARY KEY (id);


--
-- TOC entry 3988 (class 2606 OID 65583)
-- Name: user_roles PK_8acd5cf26ebd158416f477de799; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "PK_8acd5cf26ebd158416f477de799" PRIMARY KEY (id);


--
-- TOC entry 3974 (class 2606 OID 65550)
-- Name: permissions PK_920331560282b8bd21bb02290df; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT "PK_920331560282b8bd21bb02290df" PRIMARY KEY (id);


--
-- TOC entry 4003 (class 2606 OID 65612)
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- TOC entry 3983 (class 2606 OID 65574)
-- Name: roles PK_c1433d71a4838793a49dcad46ab; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT "PK_c1433d71a4838793a49dcad46ab" PRIMARY KEY (id);


--
-- TOC entry 4033 (class 2606 OID 65684)
-- Name: team_members PK_ca3eae89dcf20c9fd95bf7460aa; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT "PK_ca3eae89dcf20c9fd95bf7460aa" PRIMARY KEY (id);


--
-- TOC entry 4081 (class 2606 OID 65757)
-- Name: sla_configurations PK_cc111d437f25d1b3e995a18b815; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sla_configurations
    ADD CONSTRAINT "PK_cc111d437f25d1b3e995a18b815" PRIMARY KEY (id);


--
-- TOC entry 3923 (class 2606 OID 65420)
-- Name: companies PK_d4bc3e82a314fa9e29f652c2c22; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT "PK_d4bc3e82a314fa9e29f652c2c22" PRIMARY KEY (id);


--
-- TOC entry 4075 (class 2606 OID 65742)
-- Name: ticket_status_history PK_d989dae9e6078a6d4ce1aca63f7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_status_history
    ADD CONSTRAINT "PK_d989dae9e6078a6d4ce1aca63f7" PRIMARY KEY (id);


--
-- TOC entry 3940 (class 2606 OID 65461)
-- Name: spaces PK_dbe542974aca57afcb60709d4c8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT "PK_dbe542974aca57afcb60709d4c8" PRIMARY KEY (id);


--
-- TOC entry 3934 (class 2606 OID 65447)
-- Name: space_categories PK_e0f1bea40cb0d926db6d2f75c58; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_categories
    ADD CONSTRAINT "PK_e0f1bea40cb0d926db6d2f75c58" PRIMARY KEY (id);


--
-- TOC entry 3990 (class 2606 OID 65585)
-- Name: user_roles UQ_47597cd66874e24b829fce08616; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "UQ_47597cd66874e24b829fce08616" UNIQUE (company_id, user_id, role_id);


--
-- TOC entry 3925 (class 2606 OID 65422)
-- Name: companies UQ_80af3e6808151c3210b4d5a2185; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT "UQ_80af3e6808151c3210b4d5a2185" UNIQUE (code);


--
-- TOC entry 3980 (class 2606 OID 65561)
-- Name: role_permissions UQ_a3a530e31ac1a2b85bd0f5de7ff; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT "UQ_a3a530e31ac1a2b85bd0f5de7ff" UNIQUE (company_id, role_id, permission_id);


--
-- TOC entry 4093 (class 2606 OID 65791)
-- Name: holidays UQ_aae1d4826550cc571c00ab646ec; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT "UQ_aae1d4826550cc571c00ab646ec" UNIQUE (company_id, holiday_date);


--
-- TOC entry 3936 (class 2606 OID 65449)
-- Name: space_categories UQ_e665d6d372ae115878b2eec6cbc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.space_categories
    ADD CONSTRAINT "UQ_e665d6d372ae115878b2eec6cbc" UNIQUE (code);


--
-- TOC entry 4035 (class 2606 OID 65686)
-- Name: team_members UQ_ee8332b3b9d2076533bc1c33031; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT "UQ_ee8332b3b9d2076533bc1c33031" UNIQUE (company_id, team_id, user_id);


--
-- TOC entry 4131 (class 2606 OID 66617)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 4140 (class 2606 OID 66629)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- TOC entry 4117 (class 2606 OID 66074)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4122 (class 2606 OID 66511)
-- Name: priority priority_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.priority
    ADD CONSTRAINT priority_pkey PRIMARY KEY (id);


--
-- TOC entry 4135 (class 2606 OID 66619)
-- Name: cities uq_cities_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT uq_cities_name UNIQUE (name);


--
-- TOC entry 4142 (class 2606 OID 66631)
-- Name: locations uq_locations_city_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT uq_locations_city_name UNIQUE (city_id, name);


--
-- TOC entry 4124 (class 2606 OID 66513)
-- Name: priority uq_priority_company_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.priority
    ADD CONSTRAINT uq_priority_company_code UNIQUE (company_id, code);


--
-- TOC entry 4147 (class 2606 OID 66669)
-- Name: user_devices uq_user_devices_user_token; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT uq_user_devices_user_token UNIQUE (user_id, fcm_token);


--
-- TOC entry 4109 (class 2606 OID 66050)
-- Name: user_villas uq_user_villas_company_user_villa; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_villas
    ADD CONSTRAINT uq_user_villas_company_user_villa UNIQUE (company_id, user_id, villa_id);


--
-- TOC entry 4149 (class 2606 OID 66667)
-- Name: user_devices user_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_pkey PRIMARY KEY (id);


--
-- TOC entry 4111 (class 2606 OID 66048)
-- Name: user_villas user_villas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_villas
    ADD CONSTRAINT user_villas_pkey PRIMARY KEY (id);


--
-- TOC entry 4129 (class 2606 OID 66597)
-- Name: villa_type_configs villa_type_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.villa_type_configs
    ADD CONSTRAINT villa_type_configs_pkey PRIMARY KEY (id);


--
-- TOC entry 4006 (class 1259 OID 65631)
-- Name: IDX_03f9cf4dc37ebc8138b1f12b82; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_03f9cf4dc37ebc8138b1f12b82" ON public.ticket_comments USING btree (company_id, ticket_id);


--
-- TOC entry 4082 (class 1259 OID 65775)
-- Name: IDX_04a9a534be600926fc42bfd50c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_04a9a534be600926fc42bfd50c" ON public.ticket_sla USING btree (company_id, response_deadline);


--
-- TOC entry 4045 (class 1259 OID 65727)
-- Name: IDX_04c4a35a2f0fba54d2e4b25df8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_04c4a35a2f0fba54d2e4b25df8" ON public.maintenance_tickets USING btree (company_id, space_id);


--
-- TOC entry 4014 (class 1259 OID 65647)
-- Name: IDX_062cde1faba7afe6858e05a9f2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_062cde1faba7afe6858e05a9f2" ON public.ticket_attachments USING btree (company_id, ticket_id);


--
-- TOC entry 4046 (class 1259 OID 65720)
-- Name: IDX_07e4b179810fab38e040b68f5f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_07e4b179810fab38e040b68f5f" ON public.maintenance_tickets USING btree (company_id, category_id);


--
-- TOC entry 3926 (class 1259 OID 65436)
-- Name: IDX_081ac6a70eb4428a755d7d2d31; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_081ac6a70eb4428a755d7d2d31" ON public.sites USING btree (company_id, code);


--
-- TOC entry 4007 (class 1259 OID 65629)
-- Name: IDX_09d4754650d38d118696a3c692; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_09d4754650d38d118696a3c692" ON public.ticket_comments USING btree (company_id, comment_type);


--
-- TOC entry 3945 (class 1259 OID 65477)
-- Name: IDX_0edfc6986b938997f301f94743; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_0edfc6986b938997f301f94743" ON public.villas USING btree (company_id, site_id);


--
-- TOC entry 4094 (class 1259 OID 65807)
-- Name: IDX_13a9f0496bbdaa2275f38d8aa6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_13a9f0496bbdaa2275f38d8aa6" ON public.audit_logs USING btree (company_id, created_at);


--
-- TOC entry 3993 (class 1259 OID 65599)
-- Name: IDX_14a9f5ed4c4392aca23f968f9e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_14a9f5ed4c4392aca23f968f9e" ON public.acl_entries USING btree (company_id, resource_type, resource_id);


--
-- TOC entry 4047 (class 1259 OID 65731)
-- Name: IDX_1bf3fe533cb84f9c3521027687; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_1bf3fe533cb84f9c3521027687" ON public.maintenance_tickets USING btree (company_id, ticket_type);


--
-- TOC entry 3967 (class 1259 OID 65539)
-- Name: IDX_1f1839eb477b1b6e82c010738d; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_1f1839eb477b1b6e82c010738d" ON public.refresh_tokens USING btree (company_id, token);


--
-- TOC entry 4025 (class 1259 OID 65673)
-- Name: IDX_2198e5779072691b267f2e41cc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_2198e5779072691b267f2e41cc" ON public.ticket_categories USING btree (company_id, name);


--
-- TOC entry 4083 (class 1259 OID 65777)
-- Name: IDX_283bc514bb82d9ae6343643296; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_283bc514bb82d9ae6343643296" ON public.ticket_sla USING btree (company_id, ticket_id);


--
-- TOC entry 3946 (class 1259 OID 65476)
-- Name: IDX_330671398081ac4822b9722330; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_330671398081ac4822b9722330" ON public.villas USING btree (company_id, is_active);


--
-- TOC entry 3968 (class 1259 OID 65538)
-- Name: IDX_39ef65aa7bd322c6fbab572a27; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_39ef65aa7bd322c6fbab572a27" ON public.refresh_tokens USING btree (company_id, user_id);


--
-- TOC entry 4030 (class 1259 OID 65688)
-- Name: IDX_3ac26edb0590b71fc902d9a437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_3ac26edb0590b71fc902d9a437" ON public.team_members USING btree (company_id, team_id);


--
-- TOC entry 3999 (class 1259 OID 65614)
-- Name: IDX_3be6ae55e572b0ad4ab66060fd; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_3be6ae55e572b0ad4ab66060fd" ON public.users USING btree (company_id, external_id) WHERE (external_id IS NOT NULL);


--
-- TOC entry 4048 (class 1259 OID 65729)
-- Name: IDX_3eb5a925f4ecaf3acb0d06c25f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_3eb5a925f4ecaf3acb0d06c25f" ON public.maintenance_tickets USING btree (company_id, villa_id);


--
-- TOC entry 3975 (class 1259 OID 65562)
-- Name: IDX_428ae26aa34981e201fa959fee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_428ae26aa34981e201fa959fee" ON public.role_permissions USING btree (company_id, permission_id);


--
-- TOC entry 3964 (class 1259 OID 65527)
-- Name: IDX_5910d4e10f2e924f8006f43111; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_5910d4e10f2e924f8006f43111" ON public.notification_audit_logs USING btree (company_id, created_at);


--
-- TOC entry 4101 (class 1259 OID 65819)
-- Name: IDX_5e61b0220297ebbd0d0d6330dc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_5e61b0220297ebbd0d0d6330dc" ON public.hierarchy_nodes USING btree (company_id, type);


--
-- TOC entry 4049 (class 1259 OID 65728)
-- Name: IDX_6011c9e8d3fd7627204a86151f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_6011c9e8d3fd7627204a86151f" ON public.maintenance_tickets USING btree (company_id, site_id);


--
-- TOC entry 3937 (class 1259 OID 65462)
-- Name: IDX_6392f384ff678b9ae7b4c31a43; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_6392f384ff678b9ae7b4c31a43" ON public.spaces USING btree (company_id, site_id);


--
-- TOC entry 3985 (class 1259 OID 65587)
-- Name: IDX_63f038e4b86436ae6729e65a3c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_63f038e4b86436ae6729e65a3c" ON public.user_roles USING btree (company_id, user_id);


--
-- TOC entry 3961 (class 1259 OID 65516)
-- Name: IDX_645c654a544cd825731392bd6d; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_645c654a544cd825731392bd6d" ON public.notification_templates USING btree (company_id, code, channel);


--
-- TOC entry 4072 (class 1259 OID 65743)
-- Name: IDX_656af83bde3fc30082b827d63d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_656af83bde3fc30082b827d63d" ON public.ticket_status_history USING btree (company_id, changed_by);


--
-- TOC entry 4050 (class 1259 OID 65723)
-- Name: IDX_65e5cce3895ed30d9f76da7776; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_65e5cce3895ed30d9f76da7776" ON public.maintenance_tickets USING btree (company_id, assigned_technician_id);


--
-- TOC entry 4038 (class 1259 OID 65700)
-- Name: IDX_6e04b0e10a0688572f7c1273cd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_6e04b0e10a0688572f7c1273cd" ON public.teams USING btree (company_id, is_active);


--
-- TOC entry 4000 (class 1259 OID 65615)
-- Name: IDX_72425d1279a7db35f9b6918167; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_72425d1279a7db35f9b6918167" ON public.users USING btree (company_id, email);


--
-- TOC entry 3972 (class 1259 OID 65551)
-- Name: IDX_7331684c0c5b063803a425001a; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_7331684c0c5b063803a425001a" ON public.permissions USING btree (resource, action);


--
-- TOC entry 3957 (class 1259 OID 65505)
-- Name: IDX_77bdff3ca75081dd673f9beeee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_77bdff3ca75081dd673f9beeee" ON public.notifications USING btree (company_id, recipient_user_id, created_at);


--
-- TOC entry 3953 (class 1259 OID 65492)
-- Name: IDX_7d01180dd81e971f6ce0cdcf6b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_7d01180dd81e971f6ce0cdcf6b" ON public.notification_deliveries USING btree (company_id, notification_id, channel);


--
-- TOC entry 4051 (class 1259 OID 65725)
-- Name: IDX_8406ddbf8f00289e52b335b320; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_8406ddbf8f00289e52b335b320" ON public.maintenance_tickets USING btree (company_id, priority);


--
-- TOC entry 4078 (class 1259 OID 65759)
-- Name: IDX_845cea384412b0a77e2c3f939d; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_845cea384412b0a77e2c3f939d" ON public.sla_configurations USING btree (company_id, priority);


--
-- TOC entry 3947 (class 1259 OID 65478)
-- Name: IDX_864866d64f2bdfde101503b19f; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_864866d64f2bdfde101503b19f" ON public.villas USING btree (company_id, villa_code) WHERE (villa_code IS NOT NULL);


--
-- TOC entry 4052 (class 1259 OID 65722)
-- Name: IDX_8f222ccbfa455bbaab7e6197a0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_8f222ccbfa455bbaab7e6197a0" ON public.maintenance_tickets USING btree (company_id, assigned_supervisor_id);


--
-- TOC entry 4022 (class 1259 OID 65659)
-- Name: IDX_924267c09f9e6d7d8302173d41; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_924267c09f9e6d7d8302173d41" ON public.departments USING btree (company_id, name);


--
-- TOC entry 4053 (class 1259 OID 65732)
-- Name: IDX_963eb288fa27ccf348ecefc7ce; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_963eb288fa27ccf348ecefc7ce" ON public.maintenance_tickets USING btree (company_id, ticket_number);


--
-- TOC entry 4095 (class 1259 OID 65806)
-- Name: IDX_96c882e26dc9955723ac979f97; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_96c882e26dc9955723ac979f97" ON public.audit_logs USING btree (company_id, user_id);


--
-- TOC entry 4015 (class 1259 OID 65646)
-- Name: IDX_996f34806f70ee6431f5b8fd3f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_996f34806f70ee6431f5b8fd3f" ON public.ticket_attachments USING btree (company_id, uploaded_by_id);


--
-- TOC entry 3981 (class 1259 OID 65575)
-- Name: IDX_9acb61b0b5c438c8c68f6eb91a; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_9acb61b0b5c438c8c68f6eb91a" ON public.roles USING btree (company_id, name);


--
-- TOC entry 4096 (class 1259 OID 65805)
-- Name: IDX_9d8ec799177d159fa84c8a276a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_9d8ec799177d159fa84c8a276a" ON public.audit_logs USING btree (company_id, resource_type);


--
-- TOC entry 3994 (class 1259 OID 65600)
-- Name: IDX_9f608f7661049812c43839cba3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_9f608f7661049812c43839cba3" ON public.acl_entries USING btree (company_id, resource_type, resource_id, user_id);


--
-- TOC entry 3986 (class 1259 OID 65586)
-- Name: IDX_a0531e9143e8d6acc074719fa2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_a0531e9143e8d6acc074719fa2" ON public.user_roles USING btree (company_id, role_id);


--
-- TOC entry 4016 (class 1259 OID 65645)
-- Name: IDX_a5d47d413d711e011a0a512a87; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_a5d47d413d711e011a0a512a87" ON public.ticket_attachments USING btree (company_id, attachment_type);


--
-- TOC entry 4089 (class 1259 OID 65792)
-- Name: IDX_aae1d4826550cc571c00ab646e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_aae1d4826550cc571c00ab646e" ON public.holidays USING btree (company_id, holiday_date);


--
-- TOC entry 4102 (class 1259 OID 65818)
-- Name: IDX_ae19aa710e50af6886eed8365c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_ae19aa710e50af6886eed8365c" ON public.hierarchy_nodes USING btree (company_id, "externalId");


--
-- TOC entry 4054 (class 1259 OID 65719)
-- Name: IDX_b2acc9782798a0e38f24111401; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_b2acc9782798a0e38f24111401" ON public.maintenance_tickets USING btree (company_id, parent_ticket_id);


--
-- TOC entry 4097 (class 1259 OID 65803)
-- Name: IDX_b4a48cde3ae84f710c185a732c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_b4a48cde3ae84f710c185a732c" ON public.audit_logs USING btree (company_id, resource_id);


--
-- TOC entry 4079 (class 1259 OID 65758)
-- Name: IDX_b6289a0c0b95b392aa0002c04e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_b6289a0c0b95b392aa0002c04e" ON public.sla_configurations USING btree (company_id, is_active);


--
-- TOC entry 3976 (class 1259 OID 65563)
-- Name: IDX_b76cc6b31bb7f761322f890c30; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_b76cc6b31bb7f761322f890c30" ON public.role_permissions USING btree (company_id, role_id);


--
-- TOC entry 4084 (class 1259 OID 65776)
-- Name: IDX_bc6d1da67617806a8b2a194bc3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_bc6d1da67617806a8b2a194bc3" ON public.ticket_sla USING btree (company_id, sla_status);


--
-- TOC entry 4039 (class 1259 OID 65702)
-- Name: IDX_bcf60378d4d80e027b0ee0b8ad; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_bcf60378d4d80e027b0ee0b8ad" ON public.teams USING btree (company_id, name);


--
-- TOC entry 4055 (class 1259 OID 65721)
-- Name: IDX_c04b17eac4dfe5d51661da439a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_c04b17eac4dfe5d51661da439a" ON public.maintenance_tickets USING btree (company_id, assigned_team_id);


--
-- TOC entry 4040 (class 1259 OID 65701)
-- Name: IDX_c3d40162b785e297345a26a327; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_c3d40162b785e297345a26a327" ON public.teams USING btree (company_id, department_id);


--
-- TOC entry 3938 (class 1259 OID 65463)
-- Name: IDX_c7efdf03eaf3626aec5d244b5c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_c7efdf03eaf3626aec5d244b5c" ON public.spaces USING btree (company_id, code);


--
-- TOC entry 4073 (class 1259 OID 65744)
-- Name: IDX_c8effcf37001c81141feb03c39; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_c8effcf37001c81141feb03c39" ON public.ticket_status_history USING btree (company_id, ticket_id);


--
-- TOC entry 4026 (class 1259 OID 65672)
-- Name: IDX_cd325c8f113029ebe40068d140; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cd325c8f113029ebe40068d140" ON public.ticket_categories USING btree (company_id, parent_category_id);


--
-- TOC entry 4031 (class 1259 OID 65687)
-- Name: IDX_d24eafc4a8458c7a17065df9e4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_d24eafc4a8458c7a17065df9e4" ON public.team_members USING btree (company_id, user_id);


--
-- TOC entry 4056 (class 1259 OID 65724)
-- Name: IDX_d8ea9602f3f61c99e08b525646; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_d8ea9602f3f61c99e08b525646" ON public.maintenance_tickets USING btree (company_id, created_by);


--
-- TOC entry 4098 (class 1259 OID 65804)
-- Name: IDX_e04e6e5c57f47c1b14db470b9b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_e04e6e5c57f47c1b14db470b9b" ON public.audit_logs USING btree (company_id, action);


--
-- TOC entry 3932 (class 1259 OID 65450)
-- Name: IDX_e665d6d372ae115878b2eec6cb; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_e665d6d372ae115878b2eec6cb" ON public.space_categories USING btree (code);


--
-- TOC entry 4057 (class 1259 OID 65726)
-- Name: IDX_ebf96ab15d564a553c9e4a6b67; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_ebf96ab15d564a553c9e4a6b67" ON public.maintenance_tickets USING btree (company_id, status);


--
-- TOC entry 4008 (class 1259 OID 65630)
-- Name: IDX_ef8c4df51fe4ba7b5721e6380b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_ef8c4df51fe4ba7b5721e6380b" ON public.ticket_comments USING btree (company_id, created_by_id);


--
-- TOC entry 4027 (class 1259 OID 65674)
-- Name: IDX_f4512e9a4cc4d212e791e1910d; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_f4512e9a4cc4d212e791e1910d" ON public.ticket_categories USING btree (company_id, code);


--
-- TOC entry 4085 (class 1259 OID 65774)
-- Name: IDX_f7970755c754e80559a43caa4d; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_f7970755c754e80559a43caa4d" ON public.ticket_sla USING btree (company_id, resolution_deadline);


--
-- TOC entry 3927 (class 1259 OID 65435)
-- Name: IDX_f7acce7060df0627d07b0f06d8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_f7acce7060df0627d07b0f06d8" ON public.sites USING btree (company_id, is_active);


--
-- TOC entry 4058 (class 1259 OID 66092)
-- Name: IDX_maintenance_tickets_company_id_villa_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_maintenance_tickets_company_id_villa_number" ON public.maintenance_tickets USING btree (company_id, villa_number);


--
-- TOC entry 4001 (class 1259 OID 66091)
-- Name: IDX_users_company_id_villa_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_users_company_id_villa_number" ON public.users USING btree (company_id, villa_number) WHERE (villa_number IS NOT NULL);


--
-- TOC entry 3948 (class 1259 OID 66090)
-- Name: IDX_villas_company_id_villa_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_villas_company_id_villa_number" ON public.villas USING btree (company_id, villa_number);


--
-- TOC entry 3997 (class 1259 OID 66473)
-- Name: idx_acl_entries_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_acl_entries_permission_id ON public.acl_entries USING btree (company_id, permission_id) WHERE (permission_id IS NOT NULL);


--
-- TOC entry 3998 (class 1259 OID 66472)
-- Name: idx_acl_entries_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_acl_entries_user_id ON public.acl_entries USING btree (company_id, user_id) WHERE (user_id IS NOT NULL);


--
-- TOC entry 4132 (class 1259 OID 66637)
-- Name: idx_cities_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cities_active ON public.cities USING btree (is_active);


--
-- TOC entry 4133 (class 1259 OID 66638)
-- Name: idx_cities_display_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cities_display_order ON public.cities USING btree (display_order);


--
-- TOC entry 4105 (class 1259 OID 66494)
-- Name: idx_hierarchy_nodes_parentid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_hierarchy_nodes_parentid ON public.hierarchy_nodes USING btree (company_id, "parentId") WHERE ("parentId" IS NOT NULL);


--
-- TOC entry 4136 (class 1259 OID 66640)
-- Name: idx_locations_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_locations_active ON public.locations USING btree (is_active);


--
-- TOC entry 4137 (class 1259 OID 66639)
-- Name: idx_locations_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_locations_city ON public.locations USING btree (city_id);


--
-- TOC entry 4138 (class 1259 OID 66641)
-- Name: idx_locations_display_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_locations_display_order ON public.locations USING btree (display_order);


--
-- TOC entry 4061 (class 1259 OID 66480)
-- Name: idx_maintenance_tickets_acknowledged_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_acknowledged_by ON public.maintenance_tickets USING btree (company_id, acknowledged_by) WHERE (acknowledged_by IS NOT NULL);


--
-- TOC entry 4062 (class 1259 OID 66479)
-- Name: idx_maintenance_tickets_assigned_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_assigned_by ON public.maintenance_tickets USING btree (company_id, assigned_by) WHERE (assigned_by IS NOT NULL);


--
-- TOC entry 4063 (class 1259 OID 66477)
-- Name: idx_maintenance_tickets_assigned_supervisor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_assigned_supervisor_id ON public.maintenance_tickets USING btree (company_id, assigned_supervisor_id) WHERE (assigned_supervisor_id IS NOT NULL);


--
-- TOC entry 4064 (class 1259 OID 66478)
-- Name: idx_maintenance_tickets_assigned_technician_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_assigned_technician_id ON public.maintenance_tickets USING btree (company_id, assigned_technician_id) WHERE (assigned_technician_id IS NOT NULL);


--
-- TOC entry 4065 (class 1259 OID 66475)
-- Name: idx_maintenance_tickets_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_category_id ON public.maintenance_tickets USING btree (company_id, category_id) WHERE (category_id IS NOT NULL);


--
-- TOC entry 4066 (class 1259 OID 66474)
-- Name: idx_maintenance_tickets_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_created_by ON public.maintenance_tickets USING btree (company_id, created_by);


--
-- TOC entry 4067 (class 1259 OID 66476)
-- Name: idx_maintenance_tickets_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_department_id ON public.maintenance_tickets USING btree (company_id, department_id) WHERE (department_id IS NOT NULL);


--
-- TOC entry 4068 (class 1259 OID 66481)
-- Name: idx_maintenance_tickets_parent_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_parent_ticket_id ON public.maintenance_tickets USING btree (company_id, parent_ticket_id) WHERE (parent_ticket_id IS NOT NULL);


--
-- TOC entry 4069 (class 1259 OID 66654)
-- Name: idx_maintenance_tickets_rated_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_rated_by ON public.maintenance_tickets USING btree (company_id, rated_by) WHERE (rated_by IS NOT NULL);


--
-- TOC entry 4070 (class 1259 OID 66653)
-- Name: idx_maintenance_tickets_rating; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_maintenance_tickets_rating ON public.maintenance_tickets USING btree (company_id, rating) WHERE (rating IS NOT NULL);


--
-- TOC entry 3956 (class 1259 OID 66496)
-- Name: idx_notification_deliveries_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_deliveries_notification_id ON public.notification_deliveries USING btree (company_id, notification_id);


--
-- TOC entry 3960 (class 1259 OID 66495)
-- Name: idx_notifications_recipient_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_recipient_user_id ON public.notifications USING btree (company_id, recipient_user_id) WHERE (recipient_user_id IS NOT NULL);


--
-- TOC entry 4112 (class 1259 OID 66081)
-- Name: idx_password_reset_tokens_company_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_company_email ON public.password_reset_tokens USING btree (company_id, email);


--
-- TOC entry 4113 (class 1259 OID 66082)
-- Name: idx_password_reset_tokens_company_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_company_token ON public.password_reset_tokens USING btree (company_id, token);


--
-- TOC entry 4114 (class 1259 OID 66083)
-- Name: idx_password_reset_tokens_company_token_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_password_reset_tokens_company_token_unique ON public.password_reset_tokens USING btree (company_id, token) WHERE (used_at IS NULL);


--
-- TOC entry 4115 (class 1259 OID 66080)
-- Name: idx_password_reset_tokens_company_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_company_user ON public.password_reset_tokens USING btree (company_id, user_id);


--
-- TOC entry 4118 (class 1259 OID 66515)
-- Name: idx_priority_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_priority_active ON public.priority USING btree (company_id, is_active) WHERE (is_active = true);


--
-- TOC entry 4119 (class 1259 OID 66514)
-- Name: idx_priority_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_priority_company_id ON public.priority USING btree (company_id);


--
-- TOC entry 4120 (class 1259 OID 66516)
-- Name: idx_priority_display_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_priority_display_order ON public.priority USING btree (company_id, display_order);


--
-- TOC entry 3971 (class 1259 OID 66471)
-- Name: idx_refresh_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refresh_tokens_user_id ON public.refresh_tokens USING btree (company_id, user_id);


--
-- TOC entry 3984 (class 1259 OID 66582)
-- Name: idx_roles_parent_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_roles_parent_role_id ON public.roles USING btree (company_id, parent_role_id) WHERE (parent_role_id IS NOT NULL);


--
-- TOC entry 3930 (class 1259 OID 66462)
-- Name: idx_sites_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sites_company_id ON public.sites USING btree (company_id) WHERE (company_id IS NOT NULL);


--
-- TOC entry 3931 (class 1259 OID 66463)
-- Name: idx_sites_parent_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sites_parent_site_id ON public.sites USING btree (parent_site_id) WHERE (parent_site_id IS NOT NULL);


--
-- TOC entry 3941 (class 1259 OID 66464)
-- Name: idx_spaces_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_spaces_site_id ON public.spaces USING btree (company_id, site_id) WHERE (site_id IS NOT NULL);


--
-- TOC entry 3942 (class 1259 OID 66583)
-- Name: idx_spaces_siteid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_spaces_siteid ON public.spaces USING btree (company_id, "siteId") WHERE ("siteId" IS NOT NULL);


--
-- TOC entry 3943 (class 1259 OID 66465)
-- Name: idx_spaces_space_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_spaces_space_category_id ON public.spaces USING btree (company_id, space_category_id) WHERE (space_category_id IS NOT NULL);


--
-- TOC entry 3944 (class 1259 OID 66584)
-- Name: idx_spaces_spacecategoryid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_spaces_spacecategoryid ON public.spaces USING btree (company_id, "spaceCategoryId") WHERE ("spaceCategoryId" IS NOT NULL);


--
-- TOC entry 4036 (class 1259 OID 66492)
-- Name: idx_team_members_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_team_members_team_id ON public.team_members USING btree (company_id, team_id);


--
-- TOC entry 4037 (class 1259 OID 66493)
-- Name: idx_team_members_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_team_members_user_id ON public.team_members USING btree (company_id, user_id);


--
-- TOC entry 4043 (class 1259 OID 66490)
-- Name: idx_teams_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_department_id ON public.teams USING btree (company_id, department_id) WHERE (department_id IS NOT NULL);


--
-- TOC entry 4044 (class 1259 OID 66491)
-- Name: idx_teams_lead_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_lead_user_id ON public.teams USING btree (company_id, lead_user_id) WHERE (lead_user_id IS NOT NULL);


--
-- TOC entry 4019 (class 1259 OID 66488)
-- Name: idx_ticket_attachments_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_attachments_comment_id ON public.ticket_attachments USING btree (company_id, comment_id) WHERE (comment_id IS NOT NULL);


--
-- TOC entry 4020 (class 1259 OID 66487)
-- Name: idx_ticket_attachments_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_attachments_ticket_id ON public.ticket_attachments USING btree (company_id, ticket_id);


--
-- TOC entry 4021 (class 1259 OID 66489)
-- Name: idx_ticket_attachments_uploaded_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_attachments_uploaded_by_id ON public.ticket_attachments USING btree (company_id, uploaded_by_id);


--
-- TOC entry 4011 (class 1259 OID 66485)
-- Name: idx_ticket_comments_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_comments_created_by_id ON public.ticket_comments USING btree (company_id, created_by_id);


--
-- TOC entry 4012 (class 1259 OID 66486)
-- Name: idx_ticket_comments_parent_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_comments_parent_comment_id ON public.ticket_comments USING btree (company_id, parent_comment_id) WHERE (parent_comment_id IS NOT NULL);


--
-- TOC entry 4013 (class 1259 OID 66484)
-- Name: idx_ticket_comments_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_comments_ticket_id ON public.ticket_comments USING btree (company_id, ticket_id);


--
-- TOC entry 4088 (class 1259 OID 66585)
-- Name: idx_ticket_sla_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_sla_configuration_id ON public.ticket_sla USING btree (company_id, sla_configuration_id) WHERE (sla_configuration_id IS NOT NULL);


--
-- TOC entry 4076 (class 1259 OID 66483)
-- Name: idx_ticket_status_history_changed_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_status_history_changed_by ON public.ticket_status_history USING btree (company_id, changed_by) WHERE (changed_by IS NOT NULL);


--
-- TOC entry 4077 (class 1259 OID 66482)
-- Name: idx_ticket_status_history_ticket_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ticket_status_history_ticket_id ON public.ticket_status_history USING btree (company_id, ticket_id);


--
-- TOC entry 4071 (class 1259 OID 66522)
-- Name: idx_tickets_priority_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tickets_priority_id ON public.maintenance_tickets USING btree (company_id, priority_id) WHERE (priority_id IS NOT NULL);


--
-- TOC entry 4143 (class 1259 OID 66675)
-- Name: idx_user_devices_company_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_devices_company_user ON public.user_devices USING btree (company_id, user_id);


--
-- TOC entry 4144 (class 1259 OID 66677)
-- Name: idx_user_devices_fcm_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_devices_fcm_token ON public.user_devices USING btree (fcm_token);


--
-- TOC entry 4145 (class 1259 OID 66676)
-- Name: idx_user_devices_user_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_devices_user_active ON public.user_devices USING btree (user_id, is_active) WHERE (is_active = true);


--
-- TOC entry 3991 (class 1259 OID 66470)
-- Name: idx_user_roles_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_roles_role_id ON public.user_roles USING btree (company_id, role_id);


--
-- TOC entry 3992 (class 1259 OID 66469)
-- Name: idx_user_roles_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_roles_user_id ON public.user_roles USING btree (company_id, user_id);


--
-- TOC entry 4106 (class 1259 OID 66061)
-- Name: idx_user_villas_company_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_villas_company_user ON public.user_villas USING btree (company_id, user_id);


--
-- TOC entry 4107 (class 1259 OID 66062)
-- Name: idx_user_villas_company_villa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_villas_company_villa ON public.user_villas USING btree (company_id, villa_id);


--
-- TOC entry 4004 (class 1259 OID 66084)
-- Name: idx_users_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_deleted_at ON public.users USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- TOC entry 4005 (class 1259 OID 66468)
-- Name: idx_users_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_department_id ON public.users USING btree (company_id, department_id) WHERE (department_id IS NOT NULL);


--
-- TOC entry 4125 (class 1259 OID 66604)
-- Name: idx_villa_type_configs_company_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_villa_type_configs_company_active ON public.villa_type_configs USING btree (company_id, is_active);


--
-- TOC entry 4126 (class 1259 OID 66605)
-- Name: idx_villa_type_configs_company_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_villa_type_configs_company_order ON public.villa_type_configs USING btree (company_id, display_order);


--
-- TOC entry 4127 (class 1259 OID 66603)
-- Name: idx_villa_type_configs_company_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_villa_type_configs_company_type ON public.villa_type_configs USING btree (company_id, villa_type);


--
-- TOC entry 3951 (class 1259 OID 66466)
-- Name: idx_villas_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_villas_site_id ON public.villas USING btree (company_id, site_id) WHERE (site_id IS NOT NULL);


--
-- TOC entry 3952 (class 1259 OID 66467)
-- Name: idx_villas_space_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_villas_space_id ON public.villas USING btree (company_id, space_id) WHERE (space_id IS NOT NULL);


--
-- TOC entry 4230 (class 2620 OID 66643)
-- Name: cities trigger_update_cities_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_cities_updated_at BEFORE UPDATE ON public.cities FOR EACH ROW EXECUTE FUNCTION public.update_cities_updated_at();


--
-- TOC entry 4231 (class 2620 OID 66645)
-- Name: locations trigger_update_locations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_locations_updated_at BEFORE UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION public.update_locations_updated_at();


--
-- TOC entry 4232 (class 2620 OID 66679)
-- Name: user_devices trigger_update_user_devices_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_user_devices_updated_at BEFORE UPDATE ON public.user_devices FOR EACH ROW EXECUTE FUNCTION public.update_user_devices_updated_at();


--
-- TOC entry 4229 (class 2620 OID 66607)
-- Name: villa_type_configs trigger_update_villa_type_configs_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_villa_type_configs_updated_at BEFORE UPDATE ON public.villa_type_configs FOR EACH ROW EXECUTE FUNCTION public.update_villa_type_configs_updated_at();


--
-- TOC entry 4213 (class 2620 OID 66563)
-- Name: acl_entries update_acl_entries_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_acl_entries_updated_at BEFORE UPDATE ON public.acl_entries FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4200 (class 2620 OID 66553)
-- Name: companies update_companies_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON public.companies FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4217 (class 2620 OID 66564)
-- Name: departments update_departments_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON public.departments FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4225 (class 2620 OID 66578)
-- Name: hierarchy_nodes update_hierarchy_nodes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_hierarchy_nodes_updated_at BEFORE UPDATE ON public.hierarchy_nodes FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4224 (class 2620 OID 66573)
-- Name: holidays update_holidays_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_holidays_updated_at BEFORE UPDATE ON public.holidays FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4221 (class 2620 OID 66567)
-- Name: maintenance_tickets update_maintenance_tickets_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_maintenance_tickets_updated_at BEFORE UPDATE ON public.maintenance_tickets FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4208 (class 2620 OID 66577)
-- Name: notification_audit_logs update_notification_audit_logs_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_notification_audit_logs_updated_at BEFORE UPDATE ON public.notification_audit_logs FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4205 (class 2620 OID 66576)
-- Name: notification_deliveries update_notification_deliveries_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_notification_deliveries_updated_at BEFORE UPDATE ON public.notification_deliveries FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4207 (class 2620 OID 66575)
-- Name: notification_templates update_notification_templates_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_notification_templates_updated_at BEFORE UPDATE ON public.notification_templates FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4206 (class 2620 OID 66574)
-- Name: notifications update_notifications_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4227 (class 2620 OID 66579)
-- Name: password_reset_tokens update_password_reset_tokens_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_password_reset_tokens_updated_at BEFORE UPDATE ON public.password_reset_tokens FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4210 (class 2620 OID 66560)
-- Name: permissions update_permissions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_permissions_updated_at BEFORE UPDATE ON public.permissions FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4228 (class 2620 OID 66566)
-- Name: priority update_priority_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_priority_updated_at BEFORE UPDATE ON public.priority FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4209 (class 2620 OID 66562)
-- Name: refresh_tokens update_refresh_tokens_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_refresh_tokens_updated_at BEFORE UPDATE ON public.refresh_tokens FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4211 (class 2620 OID 66559)
-- Name: roles update_roles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4201 (class 2620 OID 66554)
-- Name: sites update_sites_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_sites_updated_at BEFORE UPDATE ON public.sites FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4202 (class 2620 OID 66556)
-- Name: space_categories update_space_categories_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_space_categories_updated_at BEFORE UPDATE ON public.space_categories FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4203 (class 2620 OID 66555)
-- Name: spaces update_spaces_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_spaces_updated_at BEFORE UPDATE ON public.spaces FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4219 (class 2620 OID 66572)
-- Name: team_members update_team_members_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_team_members_updated_at BEFORE UPDATE ON public.team_members FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4220 (class 2620 OID 66571)
-- Name: teams update_teams_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON public.teams FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4216 (class 2620 OID 66570)
-- Name: ticket_attachments update_ticket_attachments_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ticket_attachments_updated_at BEFORE UPDATE ON public.ticket_attachments FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4218 (class 2620 OID 66565)
-- Name: ticket_categories update_ticket_categories_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ticket_categories_updated_at BEFORE UPDATE ON public.ticket_categories FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4215 (class 2620 OID 66569)
-- Name: ticket_comments update_ticket_comments_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ticket_comments_updated_at BEFORE UPDATE ON public.ticket_comments FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4223 (class 2620 OID 66581)
-- Name: ticket_sla update_ticket_sla_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ticket_sla_updated_at BEFORE UPDATE ON public.ticket_sla FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4222 (class 2620 OID 66568)
-- Name: ticket_status_history update_ticket_status_history_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ticket_status_history_updated_at BEFORE UPDATE ON public.ticket_status_history FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4212 (class 2620 OID 66561)
-- Name: user_roles update_user_roles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_user_roles_updated_at BEFORE UPDATE ON public.user_roles FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4226 (class 2620 OID 66580)
-- Name: user_villas update_user_villas_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_user_villas_updated_at BEFORE UPDATE ON public.user_villas FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4214 (class 2620 OID 66558)
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4204 (class 2620 OID 66557)
-- Name: villas update_villas_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_villas_updated_at BEFORE UPDATE ON public.villas FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4168 (class 2606 OID 65910)
-- Name: ticket_attachments FK_0301cfaf908edba6ce419eb66b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_attachments
    ADD CONSTRAINT "FK_0301cfaf908edba6ce419eb66b0" FOREIGN KEY (ticket_id) REFERENCES public.maintenance_tickets(id);


--
-- TOC entry 4164 (class 2606 OID 65890)
-- Name: acl_entries FK_05da745ca3ce9f9d5ca74e459b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acl_entries
    ADD CONSTRAINT "FK_05da745ca3ce9f9d5ca74e459b1" FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- TOC entry 4170 (class 2606 OID 65920)
-- Name: ticket_categories FK_0c1acd10f499ed4a14c61271097; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_categories
    ADD CONSTRAINT "FK_0c1acd10f499ed4a14c61271097" FOREIGN KEY (parent_category_id) REFERENCES public.ticket_categories(id);


--
-- TOC entry 4191 (class 2606 OID 66015)
-- Name: ticket_sla FK_1130586f0376711b7c19e065a22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_sla
    ADD CONSTRAINT "FK_1130586f0376711b7c19e065a22" FOREIGN KEY (ticket_id) REFERENCES public.maintenance_tickets(id);


--
-- TOC entry 4151 (class 2606 OID 65825)
-- Name: sites FK_135843128b21e038cd9fb1d1f27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT "FK_135843128b21e038cd9fb1d1f27" FOREIGN KEY (parent_site_id) REFERENCES public.sites(id);


--
-- TOC entry 4159 (class 2606 OID 65865)
-- Name: role_permissions FK_17022daf3f885f7d35423e9971e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT "FK_17022daf3f885f7d35423e9971e" FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- TOC entry 4158 (class 2606 OID 65860)
-- Name: role_permissions FK_178199805b901ccd220ab7740ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT "FK_178199805b901ccd220ab7740ec" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- TOC entry 4174 (class 2606 OID 65940)
-- Name: teams FK_180c5cec740710dcf23f5e119b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT "FK_180c5cec740710dcf23f5e119b6" FOREIGN KEY (lead_user_id) REFERENCES public.users(id);


--
-- TOC entry 4190 (class 2606 OID 66010)
-- Name: ticket_status_history FK_1b80e7fcc35d804f1a7492bfab2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_status_history
    ADD CONSTRAINT "FK_1b80e7fcc35d804f1a7492bfab2" FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- TOC entry 4181 (class 2606 OID 65965)
-- Name: maintenance_tickets FK_263d0ee4fbdff70024af386af56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_263d0ee4fbdff70024af386af56" FOREIGN KEY (category_id) REFERENCES public.ticket_categories(id);


--
-- TOC entry 4160 (class 2606 OID 65870)
-- Name: roles FK_2c6e71b96bff7b9230de9dda83b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT "FK_2c6e71b96bff7b9230de9dda83b" FOREIGN KEY (parent_role_id) REFERENCES public.roles(id);


--
-- TOC entry 4182 (class 2606 OID 65970)
-- Name: maintenance_tickets FK_3cc3462a18bbcb3051a5b3604fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_3cc3462a18bbcb3051a5b3604fa" FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- TOC entry 4157 (class 2606 OID 65855)
-- Name: refresh_tokens FK_3ddc983c5f7bcf132fd8732c3f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT "FK_3ddc983c5f7bcf132fd8732c3f4" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4153 (class 2606 OID 65835)
-- Name: spaces FK_46a7ca91bf52e0c7678290f7ef2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT "FK_46a7ca91bf52e0c7678290f7ef2" FOREIGN KEY ("spaceCategoryId") REFERENCES public.space_categories(id);


--
-- TOC entry 4193 (class 2606 OID 66025)
-- Name: hierarchy_nodes FK_4740acaf173514b4b465a16b8a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hierarchy_nodes
    ADD CONSTRAINT "FK_4740acaf173514b4b465a16b8a2" FOREIGN KEY ("parentId") REFERENCES public.hierarchy_nodes(id) ON DELETE CASCADE;


--
-- TOC entry 4156 (class 2606 OID 65850)
-- Name: notification_deliveries FK_480dc696b3c108f40b394d65faf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_deliveries
    ADD CONSTRAINT "FK_480dc696b3c108f40b394d65faf" FOREIGN KEY ("notificationId") REFERENCES public.notifications(id) ON DELETE CASCADE;


--
-- TOC entry 4165 (class 2606 OID 65895)
-- Name: ticket_comments FK_4ee48e3e18e7c3ac35152a9fb7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_comments
    ADD CONSTRAINT "FK_4ee48e3e18e7c3ac35152a9fb7b" FOREIGN KEY (ticket_id) REFERENCES public.maintenance_tickets(id);


--
-- TOC entry 4189 (class 2606 OID 66005)
-- Name: ticket_status_history FK_52fa10cddeab4cf9d490c387a6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_status_history
    ADD CONSTRAINT "FK_52fa10cddeab4cf9d490c387a6c" FOREIGN KEY (ticket_id) REFERENCES public.maintenance_tickets(id) ON DELETE CASCADE;


--
-- TOC entry 4187 (class 2606 OID 65995)
-- Name: maintenance_tickets FK_57c6596866d91a9ec379f2f6a69; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_57c6596866d91a9ec379f2f6a69" FOREIGN KEY (assigned_team_id) REFERENCES public.teams(id);


--
-- TOC entry 4180 (class 2606 OID 65960)
-- Name: maintenance_tickets FK_5ce531aebacd974a6f05439bb18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_5ce531aebacd974a6f05439bb18" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- TOC entry 4154 (class 2606 OID 65840)
-- Name: villas FK_5e32cc5c62eaeb1f924dac979b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.villas
    ADD CONSTRAINT "FK_5e32cc5c62eaeb1f924dac979b5" FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- TOC entry 4178 (class 2606 OID 65950)
-- Name: maintenance_tickets FK_642dd8d95eea302850c0d0e6110; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_642dd8d95eea302850c0d0e6110" FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- TOC entry 4167 (class 2606 OID 65905)
-- Name: ticket_comments FK_6f565fd989db8068a54c64c84b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_comments
    ADD CONSTRAINT "FK_6f565fd989db8068a54c64c84b9" FOREIGN KEY (parent_comment_id) REFERENCES public.ticket_comments(id);


--
-- TOC entry 4183 (class 2606 OID 65975)
-- Name: maintenance_tickets FK_7c74db9b4d76b33c454873a9ceb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_7c74db9b4d76b33c454873a9ceb" FOREIGN KEY (assigned_supervisor_id) REFERENCES public.users(id);


--
-- TOC entry 4166 (class 2606 OID 65900)
-- Name: ticket_comments FK_807b1ad6bde02b07c9e4fc756f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_comments
    ADD CONSTRAINT "FK_807b1ad6bde02b07c9e4fc756f6" FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- TOC entry 4163 (class 2606 OID 65885)
-- Name: acl_entries FK_83fc92d095eaf6a8212401e9f07; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acl_entries
    ADD CONSTRAINT "FK_83fc92d095eaf6a8212401e9f07" FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4161 (class 2606 OID 65875)
-- Name: user_roles FK_87b8888186ca9769c960e926870; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "FK_87b8888186ca9769c960e926870" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4185 (class 2606 OID 65985)
-- Name: maintenance_tickets FK_8e1b3af32607f467463a587f4ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_8e1b3af32607f467463a587f4ab" FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- TOC entry 4179 (class 2606 OID 65955)
-- Name: maintenance_tickets FK_9edeada78dd0c40f4fe280ddfb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_9edeada78dd0c40f4fe280ddfb1" FOREIGN KEY (space_id) REFERENCES public.spaces(id);


--
-- TOC entry 4188 (class 2606 OID 66000)
-- Name: maintenance_tickets FK_9fc04fef47f6db7fb68fdfbb50b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_9fc04fef47f6db7fb68fdfbb50b" FOREIGN KEY (parent_ticket_id) REFERENCES public.maintenance_tickets(id);


--
-- TOC entry 4184 (class 2606 OID 65980)
-- Name: maintenance_tickets FK_a0ab81e777e2c54274ffad271b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_a0ab81e777e2c54274ffad271b7" FOREIGN KEY (assigned_technician_id) REFERENCES public.users(id);


--
-- TOC entry 4177 (class 2606 OID 65945)
-- Name: maintenance_tickets FK_abc263739343d15a7cabe01f1fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_abc263739343d15a7cabe01f1fe" FOREIGN KEY (villa_id) REFERENCES public.villas(id);


--
-- TOC entry 4162 (class 2606 OID 65880)
-- Name: user_roles FK_b23c65e50a758245a33ee35fda1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "FK_b23c65e50a758245a33ee35fda1" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- TOC entry 4192 (class 2606 OID 66020)
-- Name: ticket_sla FK_b94a19f9e3b01e4398679bc4fc1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_sla
    ADD CONSTRAINT "FK_b94a19f9e3b01e4398679bc4fc1" FOREIGN KEY (sla_configuration_id) REFERENCES public.sla_configurations(id);


--
-- TOC entry 4172 (class 2606 OID 65930)
-- Name: team_members FK_c2bf4967c8c2a6b845dadfbf3d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT "FK_c2bf4967c8c2a6b845dadfbf3d4" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4186 (class 2606 OID 65990)
-- Name: maintenance_tickets FK_c6ef62fdf470a10c416dab4977d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT "FK_c6ef62fdf470a10c416dab4977d" FOREIGN KEY (acknowledged_by) REFERENCES public.users(id);


--
-- TOC entry 4152 (class 2606 OID 65830)
-- Name: spaces FK_c898ef68a004585c3a0116c3f38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT "FK_c898ef68a004585c3a0116c3f38" FOREIGN KEY ("siteId") REFERENCES public.sites(id);


--
-- TOC entry 4150 (class 2606 OID 65820)
-- Name: sites FK_d1a96b77bb904acd03988687af4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT "FK_d1a96b77bb904acd03988687af4" FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- TOC entry 4169 (class 2606 OID 65915)
-- Name: ticket_attachments FK_d630ff7eb312f8245df1b952de1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_attachments
    ADD CONSTRAINT "FK_d630ff7eb312f8245df1b952de1" FOREIGN KEY (uploaded_by_id) REFERENCES public.users(id);


--
-- TOC entry 4173 (class 2606 OID 65935)
-- Name: teams FK_da396a3d0106549cc8a55d6d7d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT "FK_da396a3d0106549cc8a55d6d7d9" FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- TOC entry 4155 (class 2606 OID 65845)
-- Name: villas FK_e588b98e9745afe5da6920249c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.villas
    ADD CONSTRAINT "FK_e588b98e9745afe5da6920249c9" FOREIGN KEY (space_id) REFERENCES public.spaces(id);


--
-- TOC entry 4171 (class 2606 OID 65925)
-- Name: team_members FK_fdad7d5768277e60c40e01cdcea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT "FK_fdad7d5768277e60c40e01cdcea" FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- TOC entry 4198 (class 2606 OID 66632)
-- Name: locations fk_locations_city; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT fk_locations_city FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE CASCADE;


--
-- TOC entry 4196 (class 2606 OID 66075)
-- Name: password_reset_tokens fk_password_reset_tokens_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT fk_password_reset_tokens_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4175 (class 2606 OID 66517)
-- Name: maintenance_tickets fk_tickets_priority; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT fk_tickets_priority FOREIGN KEY (priority_id) REFERENCES public.priority(id) ON DELETE SET NULL;


--
-- TOC entry 4197 (class 2606 OID 66598)
-- Name: villa_type_configs fk_villa_type_configs_company; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.villa_type_configs
    ADD CONSTRAINT fk_villa_type_configs_company FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- TOC entry 4176 (class 2606 OID 66648)
-- Name: maintenance_tickets maintenance_tickets_rated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_tickets
    ADD CONSTRAINT maintenance_tickets_rated_by_fkey FOREIGN KEY (rated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4199 (class 2606 OID 66670)
-- Name: user_devices user_devices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4194 (class 2606 OID 66051)
-- Name: user_villas user_villas_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_villas
    ADD CONSTRAINT user_villas_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4195 (class 2606 OID 66056)
-- Name: user_villas user_villas_villa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_villas
    ADD CONSTRAINT user_villas_villa_id_fkey FOREIGN KEY (villa_id) REFERENCES public.villas(id) ON DELETE CASCADE;


-- Completed on 2026-01-01 17:31:54 IST

--
-- PostgreSQL database dump complete
--

\unrestrict TW5an4XixA1hTgw8VGPOJ6blrYTDMcqa8S8D13hANWhr1xYtqQQmuZeApHkcnRX

