CREATE TABLE IF NOT EXISTS soat_policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  motorcycle_id UUID NOT NULL REFERENCES motorcycles(id) ON DELETE CASCADE,
  insurer TEXT NOT NULL DEFAULT '',
  policy_number TEXT NOT NULL DEFAULT '',
  start_date DATE NOT NULL,
  expiry_date DATE NOT NULL,
  notes TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT soat_expiry_after_start CHECK (expiry_date > start_date)
);

ALTER TABLE soat_policies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own soat_policies" ON soat_policies;

CREATE POLICY "Users manage own soat_policies" ON soat_policies
  FOR ALL USING (auth.uid() = user_id);

CREATE UNIQUE INDEX IF NOT EXISTS uq_soat_motorcycle_policy
  ON soat_policies(user_id, motorcycle_id, policy_number);

CREATE INDEX IF NOT EXISTS idx_soat_motorcycle_expiry
  ON soat_policies(motorcycle_id, expiry_date DESC);

CREATE INDEX IF NOT EXISTS idx_soat_user_expiry
  ON soat_policies(user_id, expiry_date ASC);

CREATE INDEX IF NOT EXISTS idx_motorcycles_user_plate
  ON motorcycles(user_id, license_plate);

