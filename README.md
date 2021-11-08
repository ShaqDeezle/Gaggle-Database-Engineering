# Gaggle-Database-Engineering

Steps for Configuring all components as per best practices for a AWS RDS MySQL Production Environment Database


1. Go to AWS Management Console

2. Click on CloudFormation, then "Create Stack"

3. Upload a template file (must be a YAML file or JSON file)

4. Specify Stack Details
	
	Stack Name: MyRDSStack


5. Keep hitting "Next" until you see the "Create Stack" button

6. Hit "Create Stack" button

7. Wait awhile and then refresh the page by hitting the refresh button

8. Click on "Resources" Tab, and then click on the Physical I.D. link for your new Database Instance

9. Click on "Databases" tab next to RDS tab at the top

10. Click on the link under "DB Identifier"

11. You should see your "Connectivity & Security" Endpoint and Port at the bottom, and use that to connect to your database via a seperate application of your choice.
