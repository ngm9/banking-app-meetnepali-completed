# Task Overview

A mid-sized financial services company is finalizing its PostgreSQL migration for its core banking application. The system already stores data for customers, accounts, and transactions but is missing some basic constraints and indexes. Several fundamental reporting queries—such as getting all transactions for a customer and summarizing account activity—must also be written or fixed. As a backend engineer, you are to review schema design, ensure foundational data integrity, and use your SQL skills to solve basic reporting requirements on a realistic dataset.

# Database Access
- **Host:** <DROPLET_IP>
- **Port:** 5432
- **Database:** banking_db
- **Username:** bank_app_user
- **Password:** bank_secret_pw

You may use your preferred DB client (psql, DBeaver, pgAdmin, DataGrip, etc.) to connect and work.

# Helpful Tips
* Consider how different entities relate to each other and what natural dependencies exist within the data.
* Look for areas where the current structure might benefit from clearer boundaries or more explicit rules.
* Think about what ensures the stored data remains consistent and meaningful as it grows.
* Pay attention to which parts of the dataset are likely to be queried frequently and how the structure might impact responsiveness.
* Keep your approach rooted in core SQL and relational database concepts—simple, practical steps are all that is needed

# Objectives
* Strengthen the schema so that relationships and data rules are represented clearly and consistently.
* Introduce essential integrity checks that help maintain clean and reliable data.
* Identify structural adjustments that support smoother and more efficient query behavior.
* Execute representative queries to validate the structure and confirm that results align with expected real-world use cases.
* Ensure that typical lookup and reporting operations run effectively with the existing data volume.

# How to Verify
* Check that your updated schema explicitly enforces the intended relationships and constraints.
* Run sample queries tied to the objectives and confirm that outputs are accurate and logically sound
* Review query execution behavior to ensure common operations perform efficiently.
* Try a few incorrect or edge-case operations to see whether integrity safeguards behave as expected.
* Confirm that routine data retrieval tasks execute smoothly under normal usage patterns.
