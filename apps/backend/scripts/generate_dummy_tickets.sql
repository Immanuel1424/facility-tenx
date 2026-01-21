-- Generate 1000 Dummy Tickets with Complete Flow
-- This script deletes all existing tickets and creates 1000 new tickets with proper relationships

BEGIN;

-- Step 1: Delete all existing tickets (cascade will handle related records)
TRUNCATE TABLE maintenance_tickets CASCADE;

-- Step 2: Create ticket categories if they don't exist
INSERT INTO ticket_categories (id, company_id, code, name, description, display_order, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  c.id,
  'PLUMBING',
  'Plumbing',
  'Plumbing related issues',
  1,
  true,
  now(),
  now()
FROM companies c
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE code = 'PLUMBING')
LIMIT 1;

INSERT INTO ticket_categories (id, company_id, code, name, description, display_order, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  c.id,
  'ELECTRICAL',
  'Electrical',
  'Electrical related issues',
  2,
  true,
  now(),
  now()
FROM companies c
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE code = 'ELECTRICAL')
LIMIT 1;

INSERT INTO ticket_categories (id, company_id, code, name, description, display_order, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  c.id,
  'HVAC',
  'HVAC',
  'Heating, ventilation, and air conditioning',
  3,
  true,
  now(),
  now()
FROM companies c
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE code = 'HVAC')
LIMIT 1;

INSERT INTO ticket_categories (id, company_id, code, name, description, display_order, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  c.id,
  'CLEANING',
  'Cleaning',
  'Cleaning and maintenance requests',
  4,
  true,
  now(),
  now()
FROM companies c
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE code = 'CLEANING')
LIMIT 1;

INSERT INTO ticket_categories (id, company_id, code, name, description, display_order, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  c.id,
  'SECURITY',
  'Security',
  'Security related issues',
  5,
  true,
  now(),
  now()
FROM companies c
WHERE NOT EXISTS (SELECT 1 FROM ticket_categories WHERE code = 'SECURITY')
LIMIT 1;

-- Step 3: Create spaces for sites
INSERT INTO spaces (id, company_id, site_id, code, name, description, space_category_id, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  s.company_id,
  s.id,
  'LOBBY',
  'Main Lobby',
  'Main entrance lobby',
  NULL,
  true,
  now(),
  now()
FROM sites s
WHERE NOT EXISTS (SELECT 1 FROM spaces WHERE site_id = s.id AND code = 'LOBBY')
LIMIT 1;

INSERT INTO spaces (id, company_id, site_id, code, name, description, space_category_id, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  s.company_id,
  s.id,
  'PARKING',
  'Parking Area',
  'Parking and garage area',
  NULL,
  true,
  now(),
  now()
FROM sites s
WHERE NOT EXISTS (SELECT 1 FROM spaces WHERE site_id = s.id AND code = 'PARKING')
LIMIT 1;

-- Step 4: Create teams
INSERT INTO teams (id, company_id, name, description, department_id, lead_user_id, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  c.id,
  'Plumbing Team Alpha',
  'Primary plumbing maintenance team',
  d.id,
  u.id,
  true,
  now(),
  now()
FROM companies c
CROSS JOIN departments d
CROSS JOIN LATERAL (SELECT id FROM users WHERE company_id = c.id AND villa_number IS NULL LIMIT 1) u
WHERE d.name ILIKE '%plumb%' OR d.name ILIKE '%maintenance%'
LIMIT 1;

INSERT INTO teams (id, company_id, name, description, department_id, lead_user_id, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  c.id,
  'Electrical Team Beta',
  'Electrical maintenance team',
  d.id,
  u.id,
  true,
  now(),
  now()
FROM companies c
CROSS JOIN departments d
CROSS JOIN LATERAL (SELECT id FROM users WHERE company_id = c.id AND villa_number IS NULL LIMIT 1) u
WHERE d.name ILIKE '%electrical%' OR d.name ILIKE '%maintenance%'
LIMIT 1;

-- Step 5: Get reference IDs for ticket generation
DO $$
DECLARE
  company_uuid UUID;
  villa_ids UUID[];
  site_ids UUID[];
  space_ids UUID[];
  category_ids UUID[];
  department_ids UUID[];
  tenant_ids UUID[];
  staff_ids UUID[];
  team_ids UUID[];
  ticket_counter INT := 1;
  ticket_id UUID;
  ticket_number TEXT;
  villa_id UUID;
  site_id UUID;
  space_id UUID;
  category_id UUID;
  department_id UUID;
  created_by_id UUID;
  assigned_tech_id UUID;
  assigned_supervisor_id UUID;
  assigned_team_id UUID;
  ticket_type TEXT;
  status TEXT;
  priority TEXT;
  created_at TIMESTAMP;
  updated_at TIMESTAMP;
  assigned_at TIMESTAMP;
  acknowledged_at TIMESTAMP;
  scheduled_at TIMESTAMP;
  completed_at TIMESTAMP;
  closed_at TIMESTAMP;
  escalated_at TIMESTAMP;
  parent_ticket_id UUID;
  is_escalated BOOLEAN;
  escalation_level INT;
  supervisor_assigned_at TIMESTAMP;
BEGIN
  -- Get company ID
  SELECT id INTO company_uuid FROM companies LIMIT 1;
  
  -- Get arrays of reference IDs
  SELECT ARRAY_AGG(id) INTO villa_ids FROM villas LIMIT 50;
  SELECT ARRAY_AGG(id) INTO site_ids FROM sites;
  SELECT ARRAY_AGG(id) INTO space_ids FROM spaces;
  SELECT ARRAY_AGG(id) INTO category_ids FROM ticket_categories;
  SELECT ARRAY_AGG(id) INTO department_ids FROM departments;
  SELECT ARRAY_AGG(id) INTO tenant_ids FROM users WHERE villa_number IS NOT NULL LIMIT 50;
  SELECT ARRAY_AGG(id) INTO staff_ids FROM users WHERE villa_number IS NULL;
  SELECT ARRAY_AGG(id) INTO team_ids FROM teams;
  
  -- Generate 1000 tickets
  WHILE ticket_counter <= 1000 LOOP
    -- Generate ticket ID
    ticket_id := gen_random_uuid();
    ticket_number := 'TKT-' || LPAD(ticket_counter::TEXT, 6, '0');
    
    -- Random selections
    villa_id := villa_ids[1 + floor(random() * array_length(villa_ids, 1))::int];
    site_id := site_ids[1 + floor(random() * array_length(site_ids, 1))::int];
    space_id := CASE WHEN array_length(space_ids, 1) > 0 THEN space_ids[1 + floor(random() * array_length(space_ids, 1))::int] ELSE NULL END;
    category_id := category_ids[1 + floor(random() * array_length(category_ids, 1))::int];
    department_id := department_ids[1 + floor(random() * array_length(department_ids, 1))::int];
    created_by_id := tenant_ids[1 + floor(random() * array_length(tenant_ids, 1))::int];
    
    -- Ticket type distribution: 40% MAINTENANCE, 30% SERVICE_REQUEST, 15% INCIDENT, 15% INSPECTION
    ticket_type := CASE 
      WHEN random() < 0.4 THEN 'MAINTENANCE'
      WHEN random() < 0.7 THEN 'SERVICE_REQUEST'
      WHEN random() < 0.85 THEN 'INCIDENT'
      ELSE 'INSPECTION'
    END;
    
    -- Priority distribution: 10% URGENT, 20% HIGH, 40% MEDIUM, 30% LOW
    priority := CASE 
      WHEN random() < 0.1 THEN 'URGENT'
      WHEN random() < 0.3 THEN 'HIGH'
      WHEN random() < 0.7 THEN 'MEDIUM'
      ELSE 'LOW'
    END;
    
    -- Status flow distribution
    -- 20% NEW, 15% ACKNOWLEDGED, 20% ASSIGNED, 25% IN_PROGRESS, 10% COMPLETED, 5% ON_HOLD, 5% CANCELLED
    status := CASE 
      WHEN random() < 0.2 THEN 'NEW'
      WHEN random() < 0.35 THEN 'ACKNOWLEDGED'
      WHEN random() < 0.55 THEN 'ASSIGNED'
      WHEN random() < 0.8 THEN 'IN_PROGRESS'
      WHEN random() < 0.9 THEN 'COMPLETED'
      WHEN random() < 0.95 THEN 'ON_HOLD'
      ELSE 'CANCELLED'
    END;
    
    -- Timestamps based on status
    created_at := now() - (random() * interval '90 days');
    updated_at := created_at + (random() * interval '30 days');
    
    -- Assignment based on status
    assigned_tech_id := NULL;
    assigned_supervisor_id := NULL;
    assigned_team_id := NULL;
    assigned_at := NULL;
    acknowledged_at := NULL;
    scheduled_at := NULL;
    completed_at := NULL;
    closed_at := NULL;
    supervisor_assigned_at := NULL;
    
    IF status IN ('ACKNOWLEDGED', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED') THEN
      acknowledged_at := created_at + (random() * interval '2 hours');
      IF array_length(staff_ids, 1) > 0 THEN
        assigned_supervisor_id := staff_ids[1 + floor(random() * array_length(staff_ids, 1))::int];
        supervisor_assigned_at := acknowledged_at;
      END IF;
    END IF;
    
    IF status IN ('ASSIGNED', 'IN_PROGRESS', 'COMPLETED') THEN
      assigned_at := acknowledged_at + (random() * interval '4 hours');
      IF array_length(staff_ids, 1) > 0 THEN
        assigned_tech_id := staff_ids[1 + floor(random() * array_length(staff_ids, 1))::int];
      END IF;
      IF array_length(team_ids, 1) > 0 AND random() < 0.3 THEN
        assigned_team_id := team_ids[1 + floor(random() * array_length(team_ids, 1))::int];
      END IF;
      scheduled_at := assigned_at + (random() * interval '2 days');
    END IF;
    
    IF status = 'COMPLETED' THEN
      completed_at := scheduled_at + (random() * interval '3 days');
    END IF;
    
    -- closed_at is set when tenant confirms completion (handled separately)
    closed_at := NULL;
    
    -- Escalation (5% of tickets)
    is_escalated := random() < 0.05;
    escalation_level := 0;
    escalated_at := NULL;
    IF is_escalated AND status IN ('ASSIGNED', 'IN_PROGRESS') THEN
      escalation_level := 1 + floor(random() * 3)::int;
      escalated_at := assigned_at + (random() * interval '1 day');
    END IF;
    
    -- Parent ticket (10% of tickets after first 100)
    parent_ticket_id := NULL;
    IF ticket_counter > 100 AND random() < 0.1 THEN
      -- Link to a random previous ticket
      SELECT id INTO parent_ticket_id 
      FROM maintenance_tickets 
      WHERE id != ticket_id 
      ORDER BY random() 
      LIMIT 1;
    END IF;
    
    -- Insert ticket
    INSERT INTO maintenance_tickets (
      id, company_id, ticket_number, ticket_type, villa_number, villa_id, site_id, space_id,
      created_by, title, description, status, priority, category_id, department_id,
      assigned_supervisor_id, supervisor_assigned_at, assigned_technician_id, assigned_team_id,
      assigned_by, assigned_at, acknowledged_by, acknowledged_at, scheduled_at,
      technician_notes, resolution_notes, completed_at, closed_at, auto_close_at,
      tenant_confirmed, parent_ticket_id, is_escalated, escalation_level, escalated_at,
      created_at, updated_at
    ) VALUES (
      ticket_id, company_uuid, ticket_number, ticket_type::ticket_type, 
      (SELECT villa_number FROM villas WHERE id = villa_id),
      villa_id, site_id, space_id,
      created_by_id,
      CASE ticket_type
        WHEN 'MAINTENANCE' THEN 'Maintenance Request: ' || (ARRAY['Leaky faucet', 'Broken AC', 'Electrical issue', 'Door repair', 'Window fix'])[1 + floor(random() * 5)::int]
        WHEN 'SERVICE_REQUEST' THEN 'Service Request: ' || (ARRAY['Cleaning service', 'Landscaping', 'Pool maintenance', 'Garbage collection', 'Mail delivery'])[1 + floor(random() * 5)::int]
        WHEN 'INCIDENT' THEN 'Incident Report: ' || (ARRAY['Water leak', 'Power outage', 'Security breach', 'Fire alarm', 'Gas leak'])[1 + floor(random() * 5)::int]
        WHEN 'INSPECTION' THEN 'Inspection Request: ' || (ARRAY['Annual inspection', 'Safety check', 'Equipment audit', 'Compliance review', 'Quality check'])[1 + floor(random() * 5)::int]
        ELSE 'Maintenance Request: ' || (ARRAY['General maintenance', 'Routine check', 'System update', 'Equipment service', 'Facility inspection'])[1 + floor(random() * 5)::int]
      END,
      'Detailed description for ticket ' || ticket_number || '. This is a ' || LOWER(ticket_type) || ' ticket with ' || LOWER(priority) || ' priority.',
      status::maintenance_tickets_status_enum, priority::maintenance_tickets_priority_enum, category_id, department_id,
      assigned_supervisor_id, supervisor_assigned_at,
      assigned_tech_id, assigned_team_id,
      assigned_supervisor_id, assigned_at,
      assigned_supervisor_id, acknowledged_at, scheduled_at,
      CASE WHEN status IN ('IN_PROGRESS', 'COMPLETED') THEN 'Technician notes: Work in progress. Estimated completion: ' || (scheduled_at + interval '2 days')::text ELSE NULL END,
      CASE WHEN status = 'COMPLETED' THEN 'Resolution: Issue resolved successfully. All systems operational.' ELSE NULL END,
      completed_at, closed_at, 
      NULL,
      CASE WHEN status = 'COMPLETED' THEN random() < 0.8 ELSE false END,
      parent_ticket_id, is_escalated, escalation_level, escalated_at,
      created_at, updated_at
    );
    
    ticket_counter := ticket_counter + 1;
  END LOOP;
  
  RAISE NOTICE 'Generated 1000 tickets successfully';
END $$;

-- Step 6: Verify ticket generation
SELECT 
  COUNT(*) as total_tickets,
  COUNT(DISTINCT ticket_type) as ticket_types,
  COUNT(DISTINCT status) as statuses,
  COUNT(DISTINCT priority) as priorities,
  COUNT(DISTINCT villa_id) as unique_villas,
  COUNT(DISTINCT site_id) as unique_sites,
  COUNT(DISTINCT category_id) as unique_categories,
  COUNT(DISTINCT assigned_team_id) as unique_teams,
  COUNT(*) FILTER (WHERE is_escalated = true) as escalated_tickets,
  COUNT(*) FILTER (WHERE parent_ticket_id IS NOT NULL) as linked_tickets
FROM maintenance_tickets;

-- Show status distribution
SELECT 
  status,
  COUNT(*) as count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM maintenance_tickets
GROUP BY status
ORDER BY count DESC;

-- Show ticket type distribution
SELECT 
  ticket_type,
  COUNT(*) as count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM maintenance_tickets
GROUP BY ticket_type
ORDER BY count DESC;

-- Show priority distribution
SELECT 
  priority,
  COUNT(*) as count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM maintenance_tickets
GROUP BY priority
ORDER BY 
  CASE priority
    WHEN 'URGENT' THEN 1
    WHEN 'HIGH' THEN 2
    WHEN 'MEDIUM' THEN 3
    WHEN 'LOW' THEN 4
  END;

COMMIT;

