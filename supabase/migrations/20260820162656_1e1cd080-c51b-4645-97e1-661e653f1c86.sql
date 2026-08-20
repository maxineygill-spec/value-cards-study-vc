CREATE TABLE public.researcher_allowlist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT ALL ON public.researcher_allowlist TO service_role;

ALTER TABLE public.researcher_allowlist ENABLE ROW LEVEL SECURITY;

INSERT INTO public.researcher_allowlist (email) VALUES
  ('maxinegill@g.harvard.edu'),
  ('tperry@fas.harvard.edu'),
  ('tperry@g.harvard.edu'),
  ('david_kidd@gse.harvard.edu'),
  ('ksiegelstechler@fas.harvard.edu'),
  ('arushisaxena@fas.harvard.edu'),
  ('arushisaxena@g.harvard.edu'),
  ('mlopes@fas.harvard.edu'),
  ('jminer@fas.harvard.edu'),
  ('palmiter@g.harvard.edu'),
  ('brian_palmiter@fas.harvard.edu'),
  ('amelia.bertaska@gmail.com')
ON CONFLICT (email) DO NOTHING;

CREATE OR REPLACE FUNCTION public.claim_researcher_role()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email text;
  v_confirmed timestamptz;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN false;
  END IF;

  SELECT lower(u.email), u.email_confirmed_at
    INTO v_email, v_confirmed
  FROM auth.users u
  WHERE u.id = auth.uid();

  IF v_email IS NULL OR v_confirmed IS NULL THEN
    RETURN false;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.researcher_allowlist a WHERE lower(a.email) = v_email) THEN
    RETURN false;
  END IF;

  INSERT INTO public.user_roles (user_id, role)
  VALUES (auth.uid(), 'researcher')
  ON CONFLICT (user_id, role) DO NOTHING;

  RETURN true;
END;
$$;

REVOKE ALL ON FUNCTION public.claim_researcher_role() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.claim_researcher_role() TO authenticated;