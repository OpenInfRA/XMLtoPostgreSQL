SET search_path TO "project_aeccc09f-7f25-46c0-975d-a9e4f7ae0444", constraints, public;
INSERT INTO "attribute_type" VALUES ('1d6f37c8-cdb7-4b0a-9a76-c3ae2513a013', 'd73aae78-f4cc-4af7-ae06-9c2b337340e7', NULL, '752fc105-f93b-4b22-bae2-87b2e31653b4', NULL, NULL);
INSERT INTO "attribute_type" VALUES ('091a2936-c1b5-4775-814c-0b4db70fe6cd', '5903ba62-20ae-46b1-a191-407d8e90a7f9', NULL, 'f5a22fd3-1b19-408c-8b6a-94f5d090d89f', NULL, NULL);
INSERT INTO "attribute_type" VALUES ('8c3b7917-8975-46bb-8c08-3aa5076f8580', '738e8c2e-7c9e-45c4-ba38-8c5e4a114729', NULL, 'f5a22fd3-1b19-408c-8b6a-94f5d090d89f', NULL, NULL);
INSERT INTO "attribute_type" VALUES ('1f39489b-657d-4568-bbaa-ea191131814d', '1674f343-7393-4e00-b3c0-3b6f365e061b', NULL, '752fc105-f93b-4b22-bae2-87b2e31653b4', NULL, NULL);
INSERT INTO "attribute_type" VALUES ('0226a839-4d1e-4a6f-aa67-d57dd5ea7de2', '116f90de-38ef-411a-a248-6649fb5d53aa', NULL, '1453be24-2b0c-4b40-a648-ecccf0f382a3', NULL, NULL);
INSERT INTO "attribute_type" VALUES ('48f06316-f5e6-441a-a5e7-77291f3879e7', '71c6827d-513b-4d80-bec4-b956ac595d2a', NULL, '752fc105-f93b-4b22-bae2-87b2e31653b4', NULL, NULL);
INSERT INTO "attribute_type" VALUES ('6c7fe6cc-0e1e-4dbd-a7a8-396dee490a8a', '143aa8f5-0916-4a27-82ef-d06fadc1f9e5', NULL, '752fc105-f93b-4b22-bae2-87b2e31653b4', NULL, '7f9d62d4-a7f2-48b7-95e1-ae52a45ea6e8');
INSERT INTO "attribute_type_x_attribute_type" VALUES ('dda25557-0fb1-4dae-bd64-44c4dd58d1d0','091a2936-c1b5-4775-814c-0b4db70fe6cd', '8c3b7917-8975-46bb-8c08-3aa5076f8580', '9ce4a45e-13b3-4bbe-ae14-04e8bc2654bb');
INSERT INTO "attribute_type_group" VALUES ('92c8b3ee-61cb-44ec-be29-312c1fbb33d6', 'e12fef7c-872a-4ab3-970c-98e19d682726', NULL, NULL);
INSERT INTO "attribute_type_group" VALUES ('dbe9b7d4-710d-4418-bd28-95004dece304', 'f876dcac-a36d-4cde-871f-e1f18a70e24f', '6d95ecf8-7a60-48a0-8de0-ee5926c708bf', NULL);
INSERT INTO "attribute_type_group" VALUES ('24e81d76-b7ea-4adf-bb46-4ee81b5b83ec', 'f6038513-5d0f-4392-877d-7727cbe2bbda', NULL, NULL);
INSERT INTO "relationship_type" VALUES ('63a9125e-7c0e-4c85-abe5-56905900a150', '5de1f2f4-e766-400a-a1cb-2fe8a4373fc3', 'c34c9b66-25b8-4e45-9abb-2854fc901aef');
INSERT INTO "project" VALUES ('aeccc09f-7f25-46c0-975d-a9e4f7ae0444', 'd4bbc73b-85ed-4b63-9568-061d71742063', 'b40828c1-6ba8-4a84-aa32-6b234774a819', NULL);
INSERT INTO "topic_characteristic" VALUES ('3aac556e-0ca7-4d0f-8f6a-1886174b00c7', '829b6c94-e5db-4b78-ae90-fe3be19ee261', '5de1f2f4-e766-400a-a1cb-2fe8a4373fc3', 'aeccc09f-7f25-46c0-975d-a9e4f7ae0444');
INSERT INTO "topic_characteristic" VALUES ('3b218dd8-09a0-42e0-b570-efaba66c4c31', '6dcec2b0-5231-42f2-a65d-42eeacdbba70', 'f534260a-1173-41e3-99a7-98b4103b5e16', 'aeccc09f-7f25-46c0-975d-a9e4f7ae0444');
INSERT INTO "topic_characteristic" VALUES ('5bb8588a-8f0a-4198-a7cc-96ce498731a9', '52b01345-2afb-4fef-93c7-9b9c08ae9761', 'e1d98bbb-d7c7-48fa-a770-57a3664fb38e', 'aeccc09f-7f25-46c0-975d-a9e4f7ae0444');
INSERT INTO "multiplicity" VALUES ('2d8bc741-c775-4932-b9ea-83f7251eee04', '0', '4');
INSERT INTO "multiplicity" VALUES ('dd051168-b938-4b2f-9361-cfbc7fc5dce4', '1', '1');
INSERT INTO "attribute_type_group_to_topic_characteristic" VALUES ('b92c8ce1-278b-4926-8490-24918ac1799a','92c8b3ee-61cb-44ec-be29-312c1fbb33d6', '3aac556e-0ca7-4d0f-8f6a-1886174b00c7', '2d8bc741-c775-4932-b9ea-83f7251eee04', '1');
INSERT INTO "attribute_type_group_to_topic_characteristic" VALUES ('4b75cfc5-cf3b-4ac0-b132-75bcf83b8e19','dbe9b7d4-710d-4418-bd28-95004dece304', '3b218dd8-09a0-42e0-b570-efaba66c4c31', '2d8bc741-c775-4932-b9ea-83f7251eee04', '1');
INSERT INTO "attribute_type_group_to_topic_characteristic" VALUES ('a381262e-2d5f-405e-9e8b-98bd43155ea0','24e81d76-b7ea-4adf-bb46-4ee81b5b83ec', '5bb8588a-8f0a-4198-a7cc-96ce498731a9', '2d8bc741-c775-4932-b9ea-83f7251eee04', '1');
INSERT INTO "relationship_type_to_topic_characteristic" VALUES ('ac2fdceb-92a4-4c19-affe-89a3c34f1562', '3b218dd8-09a0-42e0-b570-efaba66c4c31', '63a9125e-7c0e-4c85-abe5-56905900a150', '2d8bc741-c775-4932-b9ea-83f7251eee04');
INSERT INTO "topic_instance" VALUES ('fab4e287-3b8e-48fa-9282-63fc123dff47', '3aac556e-0ca7-4d0f-8f6a-1886174b00c7');
INSERT INTO "topic_instance" VALUES ('53f85242-2cb0-427c-882b-d4bdbf27e360', '3b218dd8-09a0-42e0-b570-efaba66c4c31');
INSERT INTO "topic_instance" VALUES ('07be6a08-d8a7-4c80-ae7e-281d2d306a59', '3b218dd8-09a0-42e0-b570-efaba66c4c31');
INSERT INTO "topic_instance" VALUES ('0e15494c-e461-448c-81a3-f362b782feaa', '3b218dd8-09a0-42e0-b570-efaba66c4c31');
INSERT INTO "topic_instance" VALUES ('d99a195f-f977-4b88-8246-1c3caca45fd4', '3b218dd8-09a0-42e0-b570-efaba66c4c31');
INSERT INTO "topic_instance" VALUES ('e01a9b89-a9dd-4a18-ac60-3bdf08dff492', '5bb8588a-8f0a-4198-a7cc-96ce498731a9');
INSERT INTO "topic_instance" VALUES ('c335daac-5bb3-4152-9b47-84b9694a7fbe', '5bb8588a-8f0a-4198-a7cc-96ce498731a9');
INSERT INTO "topic_instance_x_topic_instance" VALUES ('3015f577-18be-43cb-924d-4b0379286189','53f85242-2cb0-427c-882b-d4bdbf27e360', 'fab4e287-3b8e-48fa-9282-63fc123dff47', '63a9125e-7c0e-4c85-abe5-56905900a150');
INSERT INTO "topic_instance_x_topic_instance" VALUES ('bbb35a1b-ae3a-47de-bd61-e4f1ae1f51ae','07be6a08-d8a7-4c80-ae7e-281d2d306a59', 'fab4e287-3b8e-48fa-9282-63fc123dff47', '63a9125e-7c0e-4c85-abe5-56905900a150');
INSERT INTO "topic_instance_x_topic_instance" VALUES ('45bb0d79-66bd-4c2b-b137-539ce5915049','0e15494c-e461-448c-81a3-f362b782feaa', 'fab4e287-3b8e-48fa-9282-63fc123dff47', '63a9125e-7c0e-4c85-abe5-56905900a150');
INSERT INTO "topic_instance_x_topic_instance" VALUES ('cff9ade3-3fb4-4221-929d-4e3d8433af06','d99a195f-f977-4b88-8246-1c3caca45fd4', 'fab4e287-3b8e-48fa-9282-63fc123dff47', '63a9125e-7c0e-4c85-abe5-56905900a150');
INSERT INTO "attribute_type_to_attribute_type_group" VALUES ('d0fb2968-0186-4d15-b7a0-895678cf2657','091a2936-c1b5-4775-814c-0b4db70fe6cd', '92c8b3ee-61cb-44ec-be29-312c1fbb33d6', 'b92c8ce1-278b-4926-8490-24918ac1799a', 'dd051168-b938-4b2f-9361-cfbc7fc5dce4',NULL,'1');
INSERT INTO "attribute_type_to_attribute_type_group" VALUES ('dd0f585e-b270-4140-a2be-eaff549e7dd1','8c3b7917-8975-46bb-8c08-3aa5076f8580', '92c8b3ee-61cb-44ec-be29-312c1fbb33d6', 'b92c8ce1-278b-4926-8490-24918ac1799a', 'dd051168-b938-4b2f-9361-cfbc7fc5dce4',NULL,'1');
INSERT INTO "attribute_type_to_attribute_type_group" VALUES ('193b97e6-e8f8-4a4e-aa47-2b72916d24e8','1d6f37c8-cdb7-4b0a-9a76-c3ae2513a013', 'dbe9b7d4-710d-4418-bd28-95004dece304', '4b75cfc5-cf3b-4ac0-b132-75bcf83b8e19', 'dd051168-b938-4b2f-9361-cfbc7fc5dce4',NULL,'1');
INSERT INTO "attribute_type_to_attribute_type_group" VALUES ('7dee86a0-b04d-4236-8516-bc7aa8baba98','8c3b7917-8975-46bb-8c08-3aa5076f8580', 'dbe9b7d4-710d-4418-bd28-95004dece304', '4b75cfc5-cf3b-4ac0-b132-75bcf83b8e19', 'dd051168-b938-4b2f-9361-cfbc7fc5dce4',NULL,'1');
INSERT INTO "attribute_type_to_attribute_type_group" VALUES ('df853fd6-c1eb-48a0-91ab-9bf194ca4dd5','1f39489b-657d-4568-bbaa-ea191131814d', '24e81d76-b7ea-4adf-bb46-4ee81b5b83ec', 'a381262e-2d5f-405e-9e8b-98bd43155ea0', 'dd051168-b938-4b2f-9361-cfbc7fc5dce4',NULL,'1');
INSERT INTO "attribute_type_to_attribute_type_group" VALUES ('005d75d2-bd72-4a81-a83f-ec0596225581','0226a839-4d1e-4a6f-aa67-d57dd5ea7de2', '24e81d76-b7ea-4adf-bb46-4ee81b5b83ec', 'a381262e-2d5f-405e-9e8b-98bd43155ea0', 'dd051168-b938-4b2f-9361-cfbc7fc5dce4',NULL,'1');
INSERT INTO "attribute_type_to_attribute_type_group" VALUES ('c05bbd28-a61f-4e98-9553-0dd599f755c8','48f06316-f5e6-441a-a5e7-77291f3879e7', '92c8b3ee-61cb-44ec-be29-312c1fbb33d6', 'b92c8ce1-278b-4926-8490-24918ac1799a', '2d8bc741-c775-4932-b9ea-83f7251eee04',NULL,'1');
INSERT INTO "attribute_type_to_attribute_type_group" VALUES ('c9bbf3a5-9bf0-4e3d-aea6-a5a63f4e2a31','6c7fe6cc-0e1e-4dbd-a7a8-396dee490a8a', '92c8b3ee-61cb-44ec-be29-312c1fbb33d6', 'b92c8ce1-278b-4926-8490-24918ac1799a', 'dd051168-b938-4b2f-9361-cfbc7fc5dce4','d926bf7f-9b1f-43ac-a112-2123236e8643','1');
INSERT INTO "attribute_value_domain" VALUES ('12557eb3-7b46-4245-ad6c-9b7b4278c191', 'c9bbf3a5-9bf0-4e3d-aea6-a5a63f4e2a31', 'fab4e287-3b8e-48fa-9282-63fc123dff47', '18478c40-74b2-4aea-8895-40e10fbf42bf');
INSERT INTO "attribute_value_value" VALUES ('3a1175c5-9a7a-4526-b0f3-03b85a4ec770', 'd0fb2968-0186-4d15-b7a0-895678cf2657', 'fab4e287-3b8e-48fa-9282-63fc123dff47', '7fb8bce8-b246-4fca-9c6c-23d3b8d6b6cd');
INSERT INTO "attribute_value_value" VALUES ('d8f54644-6f0e-4bef-b1f7-d088c06c1c88', 'dd0f585e-b270-4140-a2be-eaff549e7dd1', 'fab4e287-3b8e-48fa-9282-63fc123dff47', 'd5375e94-d7e8-45e0-af52-08d952d8f3f0');
INSERT INTO "attribute_value_value" VALUES ('b1b9277d-eb84-4308-b127-1b5fdc5677dd', '7dee86a0-b04d-4236-8516-bc7aa8baba98', '53f85242-2cb0-427c-882b-d4bdbf27e360', '8e7db6d5-cfe9-48a4-a6fb-01631b43a0c9');
INSERT INTO "attribute_value_value" VALUES ('f0a4e4cd-d1af-4e58-be92-487b4cd45160', '193b97e6-e8f8-4a4e-aa47-2b72916d24e8', '53f85242-2cb0-427c-882b-d4bdbf27e360', 'd2f2b8f8-d4cd-4132-a594-f77057a85842');
INSERT INTO "attribute_value_value" VALUES ('01e85d4d-a620-420a-81fc-224ecf51f73f', '7dee86a0-b04d-4236-8516-bc7aa8baba98', '07be6a08-d8a7-4c80-ae7e-281d2d306a59', 'd97352e5-35a6-485b-adb1-b2b16fb70c01');
INSERT INTO "attribute_value_value" VALUES ('cfdeb3d7-a3c5-4a5e-9a2e-145b08c7d203', '193b97e6-e8f8-4a4e-aa47-2b72916d24e8', '07be6a08-d8a7-4c80-ae7e-281d2d306a59', '104e48ce-3b77-420a-8615-f7f83acbd675');
INSERT INTO "attribute_value_value" VALUES ('5b658b7b-e035-449e-9403-0a319654be68', '7dee86a0-b04d-4236-8516-bc7aa8baba98', '0e15494c-e461-448c-81a3-f362b782feaa', 'ef77bac4-4756-4020-9e77-db0e70d3c86c');
INSERT INTO "attribute_value_value" VALUES ('f156b555-4603-473a-b21c-d5211601aedb', '193b97e6-e8f8-4a4e-aa47-2b72916d24e8', '0e15494c-e461-448c-81a3-f362b782feaa', '1512b94c-dd78-4d16-99ed-ca03b5a0b769');
INSERT INTO "attribute_value_value" VALUES ('d6fbc1ec-c0cd-43f4-8f26-0b8f15070d50', '7dee86a0-b04d-4236-8516-bc7aa8baba98', 'd99a195f-f977-4b88-8246-1c3caca45fd4', '6989ec52-5c5e-4179-abd0-fb3c212974d0');
INSERT INTO "attribute_value_value" VALUES ('76fab6bf-1402-4691-8bd2-4deb3dbd0bd6', '193b97e6-e8f8-4a4e-aa47-2b72916d24e8', 'd99a195f-f977-4b88-8246-1c3caca45fd4', '28a15c62-239e-474e-8785-ddab759022c6');
INSERT INTO "attribute_value_value" VALUES ('faaac2c3-07f5-4c9b-bdd1-ed65f146d14d', 'df853fd6-c1eb-48a0-91ab-9bf194ca4dd5', 'e01a9b89-a9dd-4a18-ac60-3bdf08dff492', 'd5a0b050-1a4c-4b7e-a412-8d408eb5ef2d');
INSERT INTO "attribute_value_value" VALUES ('d0a6222c-f38a-40d1-af2c-9ea8633d6d1b', '005d75d2-bd72-4a81-a83f-ec0596225581', 'e01a9b89-a9dd-4a18-ac60-3bdf08dff492', '5833a6d2-373f-416b-8ceb-daab82c05da6');
INSERT INTO "attribute_value_value" VALUES ('2174b9d1-785e-4b0f-9a7d-37649697eeec', 'df853fd6-c1eb-48a0-91ab-9bf194ca4dd5', 'c335daac-5bb3-4152-9b47-84b9694a7fbe', 'bbb5af67-d5f9-4dba-9c74-fd5a8c6fbc8e');
INSERT INTO "attribute_value_value" VALUES ('01f00f36-ac30-4c83-9dac-ef1b24abc79c', '005d75d2-bd72-4a81-a83f-ec0596225581', 'c335daac-5bb3-4152-9b47-84b9694a7fbe', '9e4e7cbc-9537-4e21-a377-3e73a6da301d');
INSERT INTO "attribute_value_value" VALUES ('9e48554c-f787-461d-94c0-a81bfdefa021', 'c05bbd28-a61f-4e98-9553-0dd599f755c8', 'fab4e287-3b8e-48fa-9282-63fc123dff47', '79ff2ce3-dae5-4b13-b227-59cbb6281d23');
INSERT INTO "attribute_value_value" VALUES ('d6e303f1-cc19-4b5f-be95-5b7f582737d3', 'c05bbd28-a61f-4e98-9553-0dd599f755c8', 'fab4e287-3b8e-48fa-9282-63fc123dff47', '0628d4e1-0b14-41be-ad6a-8e67a15c22cf');
