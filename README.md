
# aws-terraform-vpc-project2


https://www.linkedin.com/pulse/creating-aws-vpc-using-terraform-some-additional-features-mishra/


Terraform Run: VPC
Now we have the stage set with the code, the file structure and the prerequisites met, we can start pulling the Terraform strings to create our VPC.

The "correct" steps to run terraform code include:

==> terraform init:
This step initializes the plugins and providers, which are needed to work with the various resources we “coded.”

==> terraform plan:
An optional step, but a silent hero that confirms our configuration code syntax is correct and provides an overview of which resources will be created in your infrastructure world. As more complex code and modifications are done to your code, this step is a lifesaver when it comes to crossing the t's and dotting the i's before committing. Notice the second screenshot shows that 18 resources will be added.

==> terraform apply:
This is the actual launch step that will create your infrastructure. Notice in the second screenshot that you will have to confirm the actions.

Confirmation
If all goes well in the previous sections, you can log into the AWS console and confirm all resources were successfully created.
