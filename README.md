# 🚴‍♂️ Projet dbt — Les vélos de Didier

## 🏢 Contexte

**Les vélos de Didier** est une entreprise familiale locale spécialisée dans la vente de vélos et d’accessoires liés au cyclisme.  
L’objectif du projet dbt est de **centraliser, nettoyer et modéliser** les données issues des fichiers bruts afin de permettre :

- Une **analyse client** (fidélisation, panier moyen, récurrence)
- Une **analyse produit** (ventes, chiffre d’affaires, performance des gammes)

Ces modèles alimenteront des **tableaux de bord BI** (ex. Looker Studio, Power BI) pour aider à la prise de décision.

---

## 🧱 Structure du projet

```text
didier_bikes_dbt/
├─ models/
│  ├─ raw/                # Tables externes BigQuery pointant vers les CSV GCS
│  ├─ staging/            # Nettoyage, typage, et jointures initiales
│  └─ marts/              # Jeux de données finaux pour la BI (KPI, agrégats)
├─ macros/                # Macros personnalisées et tests custom
├─ tests/                 # Tests additionnels si besoin
├─ snapshots/             # Snapshots d’historisation éventuels
├─ seeds/                 # Données statiques
├─ dbt_project.yml        # Configuration du projet dbt
├─ packages.yml           # Dépendances dbt externes (dbt-utils, dbt-external-tables…)
├─ requirements.txt       # Dépendances Python/dbt
└─ start_dbt.sh           # Script automatisé de démarrage du projet
```

---

## 🔗 Sources de données

Les données brutes sont stockées sur **Google Cloud Storage (GCS)** sous forme de fichiers CSV.

| Table | Description | Localisation |
|-------|--------------|---------------|
| `raw_customers` | Données clients | `gs://didier-bikes-raw/customers/*.csv` |
| `raw_orders` | Données commandes | `gs://didier-bikes-raw/orders/*.csv` |
| `raw_order_items` | Lignes de commande | `gs://didier-bikes-raw/order_items/*.csv` |
| `raw_products` | Catalogue produits | `gs://didier-bikes-raw/products/*.csv` |

Ces tables sont configurées via le package **`dbt-external-tables`** et matérialisées dans BigQuery.

---

## 🧮 Modèles dbt

### Staging (`stg_`)
- Nettoyage, typage et filtrage des données brutes.
- Gestion des clés et relations.

| Modèle | Description |
|--------|--------------|
| `stg_customers` | Nettoyage et typage des clients |
| `stg_orders` | Nettoyage et conversion des dates en `TIMESTAMP` |
| `stg_order_items` | Déduplication et typage des lignes de commande |
| `stg_products` | Standardisation des informations produits |

### Marts (`marts_`)
- Jeux de données finaux pour la BI.

| Modèle | Description |
|--------|--------------|
| `fct_clients_analysis` | KPIs clients : nombre de commandes, panier moyen, total dépensé |
| `fct_product_sales_analysis` | KPIs produits : chiffre d’affaires, volume vendu, performance |

---

## 🧪 Tests dbt

Des tests sont définis dans les fichiers `schema.yml` :

### Tests de base
- `unique` et `not_null` sur les clés primaires (`customer_id`, `order_id`, `product_id`, `item_id`)
- `relationships` entre les tables (`order_id → stg_orders`, `product_id → stg_products`)

---

## ⚙️ Installation et configuration

### 1️⃣ Cloner le projet
#### HTTPS
```bash
git clone https://github.com/AzemoFrank/dbt_didier_bikes.git
cd didier_bikes_dbt
```

#### ou

#### SSH
```bash
git clone git@github.com:AzemoFrank/dbt_didier_bikes.git
cd didier_bikes_dbt
```

### 2️⃣ Créer et activer un environnement virtuel

#### Linux / macOS
```bash
python3 -m venv dbt-env
source dbt-env/bin/activate
```

#### Windows (PowerShell)
```powershell
python -m venv dbt-env
dbt-env\Scripts\activate
```

### 3️⃣ Installer les dépendances Python

```bash
pip install -r requirements.txt
```

> 💡 Pour régénérer ce fichier :
> ```bash
> pip freeze > requirements.txt
> ```

### 4️⃣ Installer les packages dbt

```bash
dbt deps
```

### 5️⃣ Exécuter le projet

```bash
dbt run
```

### 6️⃣ Lancer les tests

```bash
dbt test
```

### 7️⃣ Générer et consulter la documentation

```bash
dbt docs generate
dbt docs serve
```

---

## 🚀 Démarrage rapide avec `start_dbt.sh`

Un script dédié (`start_dbt.sh`) est inclus pour automatiser le lancement du projet.  
Ce script crée l’environnement virtuel (s’il n’existe pas), installe les dépendances et exécute dbt.

### Utilisation :

```bash
chmod +x start_dbt.sh
./start_dbt.sh
```

> 🧠 **Astuce** : ce script peut être modifié pour inclure des commandes personnalisées (par ex. `dbt run + dbt test + dbt docs generate`).

---

## 🧠 Bonnes pratiques

- Toujours passer par un modèle **staging** avant la couche analytique.  
- Utiliser `unique_key` pour les modèles incrémentaux.  
- Versionner les packages dbt dans `packages.yml`.  
- Mettre à jour `requirements.txt` à chaque nouvelle dépendance.  
- Ajouter des **tests et descriptions** pour chaque colonne critique.  
- Utiliser `start_dbt.sh` pour garantir un environnement cohérent entre collaborateurs.

---

## 📄 Auteur

**Projet dbt – Les vélos de Didier**  
Créé par : Frank Azemo  
Version : `1.0.0`  
Environnement : `BigQuery + GCS`  
Script de lancement : `start_dbt.sh`
