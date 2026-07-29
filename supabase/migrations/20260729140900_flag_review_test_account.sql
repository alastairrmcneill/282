-- ============================================================================
-- Shadowed test accounts, part 10/10: flag the account.
--
-- "Tester 1" -- the credentials handed to App Store review and (until the Play
-- Console pre-launch report credentials are removed) to Google's Robo crawler.
--
-- To shadow another account later, just:
--   UPDATE public.users SET is_shadowed = true WHERE id = '<uid>';
-- ============================================================================

UPDATE public.users
SET is_shadowed = true
WHERE id = 'BNJHdmKPDfeXjrx34yxavW7Feuq2';
