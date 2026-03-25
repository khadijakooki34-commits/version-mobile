-- Script pour supprimer les tables audit_logs et two_factor_auth
-- Utilisé car ces fonctionnalités sont déjà implémentées dans la version web

-- Supprimer la table audit_logs si elle existe
DROP TABLE IF EXISTS audit_logs;

-- Supprimer la table two_factor_auth si elle existe  
DROP TABLE IF EXISTS two_factor_auth;

-- Afficher un message de confirmation
SELECT 'Tables audit_logs et two_factor_auth supprimées avec succès' as message;
