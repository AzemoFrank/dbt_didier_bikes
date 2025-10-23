# README — Projet dbt : Les vélos de Didier

## 1️⃣ Contexte

Les vélos de Didier est une entreprise familiale spécialisée dans la vente de vélos et d’accessoires.
L’objectif du projet dbt est de **mettre en place des jeux de données fiables** pour :

1. Analyser la **base client** (segmentation, fidélisation, panier moyen).
2. Analyser les **performances produits** (ventes, chiffre d’affaires, stock).

Ces données alimenteront ensuite des **tableaux de bord BI** pour piloter l’activité et soutenir le développement.

---

## 2️⃣ Structure du projet

```text
didier_bikes_dbt/
├─ models/
│  ├─ raw/                # Tables sources brutes (externe CSV GCS)
│  ├─ staging/            # Modèles stg_ pour nettoyage et typage
│  └─ marts/              # Modèles marts_ pour KPIs et dashboards
├─ macros/                # Macros et tests personnalisés
├─ snapshots/             # Snapshots éventuels
├─ seeds/                 # Données statiques
├─ tests/                 # Tests additionnels
└─ dbt_project.yml        # Configuration du projet dbt
```

---

## 3️⃣ Sources de données

* **raw_customers** : données clients
* **raw_orders** : données commandes
* **raw_order_items** : lignes de commande
* **raw_products** : catalogue produits

Ces tables sont **exposées depuis Google Cloud Storage (CSV)** et ingérées dans BigQuery via dbt.

---

## 4️⃣ Modèles

### Staging (`stg_`)

* `stg_customers` : nettoyage, typage, déduplication
* `stg_orders` : conversion dates, typage
* `stg_order_items` : déduplication sur `(order_id, product_id, item_id)`
* `stg_products` : typage, conversion numeric

### Mart (`marts_`)

* `marts_customer_kpis` : nombre de commandes, total dépensé, panier moyen, dernière commande
* `marts_product_kpis` : ventes par produit, chiffre d’affaires, stock restant

---

## 5️⃣ Tests dbt

Tests principaux appliqués :

* **Unique / Not Null** : clés primaires (`customer_id`, `order_id`, `product_id`, `item_id`)
* **Relationships** : intégrité référentielle (`order_id → stg_orders`, `customer_id → stg_customers`, `product_id → stg_products`)
* **Tests métiers personnalisés** : par exemple, valeurs acceptées pour `status` commandes

---

## 6️⃣ Instructions pour exécuter le projet

1. Installer dbt et les packages nécessaires :

```bash
pip install dbt-bigquery dbt-utils dbt-external-tables
```

2. Installer les dépendances dbt :

```bash
dbt deps
```

3. Exécuter les modèles :

```bash
dbt run
```

4. Lancer les tests :

```bash
dbt test
```

5. Générer la documentation :

```bash
dbt docs generate
dbt docs serve
```

---

## 7️⃣ Bonnes pratiques

* Toujours utiliser des modèles staging pour **nettoyer et typer** les données sources.
* Définir des **clés uniques et relations** pour garantir l’intégrité.
* Documenter chaque colonne avec une **description et des tests**.
* Mettre à jour le README à chaque ajout de modèle ou nouvelle source.
