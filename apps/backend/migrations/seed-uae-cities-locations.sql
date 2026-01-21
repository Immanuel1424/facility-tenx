-- Seed script for cities and locations (UAE and Oman)
-- Dubai Region Standards for Alosool Group (www.alosoolgroup.com)

-- Insert major UAE cities
INSERT INTO cities (name, code, emirate, display_order, is_active) VALUES
  ('Dubai', 'DXB', 'Dubai', 0, true),
  ('Abu Dhabi', 'AUH', 'Abu Dhabi', 1, true),
  ('Sharjah', 'SHJ', 'Sharjah', 2, true),
  ('Ajman', 'AJM', 'Ajman', 3, true),
  ('Ras Al Khaimah', 'RAK', 'Ras Al Khaimah', 4, true),
  ('Fujairah', 'FJR', 'Fujairah', 5, true),
  ('Umm Al Quwain', 'UAQ', 'Umm Al Quwain', 6, true),
  ('Muscat', 'MCT', 'Muscat', 7, true)
ON CONFLICT (name) DO NOTHING;

-- Insert Dubai locations (areas/neighborhoods)
INSERT INTO locations (city_id, name, code, display_order, is_active)
SELECT 
  c.id,
  loc.name,
  loc.code,
  loc.display_order,
  true
FROM cities c
CROSS JOIN (VALUES
  ('Downtown Dubai', 'DTD', 0),
  ('Dubai Marina', 'DMR', 1),
  ('Jumeirah', 'JMR', 2),
  ('Business Bay', 'BSB', 3),
  ('Palm Jumeirah', 'PJM', 4),
  ('Dubai Hills', 'DHH', 5),
  ('Arabian Ranches', 'ARB', 6),
  ('Emirates Hills', 'EMH', 7),
  ('Jumeirah Lakes Towers', 'JLT', 8),
  ('Dubai Sports City', 'DSC', 9),
  ('Dubai Silicon Oasis', 'DSO', 10),
  ('International City', 'INC', 11),
  ('Dubai Land', 'DLD', 12),
  ('Al Barsha', 'ABS', 13),
  ('Al Quoz', 'AQZ', 14),
  ('Deira', 'DER', 15),
  ('Bur Dubai', 'BDB', 16),
  ('Jebel Ali', 'JBA', 17),
  ('Dubai Investment Park', 'DIP', 18),
  ('Motor City', 'MTC', 19)
) AS loc(name, code, display_order)
WHERE c.name = 'Dubai'
ON CONFLICT (city_id, name) DO NOTHING;

-- Insert Abu Dhabi locations
INSERT INTO locations (city_id, name, code, display_order, is_active)
SELECT 
  c.id,
  loc.name,
  loc.code,
  loc.display_order,
  true
FROM cities c
CROSS JOIN (VALUES
  ('Al Reem Island', 'ARI', 0),
  ('Yas Island', 'YAS', 1),
  ('Saadiyat Island', 'SDY', 2),
  ('Al Maryah Island', 'AMY', 3),
  ('Corniche Area', 'CRN', 4),
  ('Al Khalidiyah', 'AKH', 5),
  ('Al Bateen', 'ABT', 6),
  ('Al Mushrif', 'AMF', 7),
  ('Al Karamah', 'AKR', 8),
  ('Al Nahyan', 'ANH', 9)
) AS loc(name, code, display_order)
WHERE c.name = 'Abu Dhabi'
ON CONFLICT (city_id, name) DO NOTHING;

-- Insert Sharjah locations
INSERT INTO locations (city_id, name, code, display_order, is_active)
SELECT 
  c.id,
  loc.name,
  loc.code,
  loc.display_order,
  true
FROM cities c
CROSS JOIN (VALUES
  ('Al Qasimia', 'AQS', 0),
  ('Al Majaz', 'AMJ', 1),
  ('Al Nahda', 'AND', 2),
  ('Al Khan', 'AKN', 3),
  ('Al Taawun', 'ATW', 4)
) AS loc(name, code, display_order)
WHERE c.name = 'Sharjah'
ON CONFLICT (city_id, name) DO NOTHING;

-- Insert Muscat locations
INSERT INTO locations (city_id, name, code, display_order, is_active)
SELECT 
  c.id,
  loc.name,
  loc.code,
  loc.display_order,
  true
FROM cities c
CROSS JOIN (VALUES
  ('Al Khuwair', 'AKW', 0),
  ('Al Seeb', 'ASB', 1),
  ('Muttrah', 'MTR', 2),
  ('Ruwi', 'RUW', 3),
  ('Qurum', 'QRM', 4),
  ('Al Ghubrah', 'AGB', 5),
  ('Bausher', 'BSH', 6),
  ('Al Azaiba', 'AZB', 7),
  ('Al Wadi Al Kabir', 'AWK', 8),
  ('Madinat Qaboos', 'MQB', 9),
  ('Al Maabilah', 'AMB', 10),
  ('Al Hail', 'AHL', 11),
  ('Al Amerat', 'AMR', 12),
  ('Al Khoud', 'AKD', 13),
  ('Al Ansab', 'ANS', 14)
) AS loc(name, code, display_order)
WHERE c.name = 'Muscat'
ON CONFLICT (city_id, name) DO NOTHING;

-- Verify the inserts
SELECT 
  c.name as city,
  c.emirate,
  COUNT(l.id) as location_count
FROM cities c
LEFT JOIN locations l ON l.city_id = c.id
WHERE c.is_active = true
GROUP BY c.id, c.name, c.emirate
ORDER BY c.display_order;

