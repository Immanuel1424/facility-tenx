-- Add new fields to villas table
ALTER TABLE villas
ADD COLUMN IF NOT EXISTS villa_type VARCHAR(50) NULL,
ADD COLUMN IF NOT EXISTS parking_slot_number VARCHAR(50) NULL,
ADD COLUMN IF NOT EXISTS meter_number VARCHAR(50) NULL,
ADD COLUMN IF NOT EXISTS water_meter_number VARCHAR(50) NULL,
ADD COLUMN IF NOT EXISTS remarks TEXT NULL;

-- Add comments for documentation
COMMENT ON COLUMN villas.villa_type IS 'Villa type - Dubai Region Standards (e.g., Studio, 1BHK, 2BHK, 3BHK, 4BHK, 5BHK, Penthouse, Duplex, Townhouse, Villa, Mansion)';
COMMENT ON COLUMN villas.parking_slot_number IS 'Parking slot number assigned to the villa';
COMMENT ON COLUMN villas.meter_number IS 'Electricity meter number';
COMMENT ON COLUMN villas.water_meter_number IS 'Water meter number';
COMMENT ON COLUMN villas.remarks IS 'Additional remarks or notes about the villa';

