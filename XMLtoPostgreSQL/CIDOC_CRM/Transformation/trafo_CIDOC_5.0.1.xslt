<?xml version="1.0" encoding="UTF-8"?>
<?altova_samplexml file:///E:/HTW_Dresden/Masterarbeit/CIDOC_CRM/Transformation/test.xml?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="/java.lang.Math" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2004/10/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:strip-space elements="*"/>
	<!-- Id der Spachumgebung -->
	<xsl:variable name="locale" select="'2'"/>
	<xsl:key name="Themeninstanz_by_ThemenauspraegungId" match="Themeninstanz" use="Themenauspraegung_Id"/>
	<xsl:key name="Themeninstanz_by_Id" match="Themeninstanz" use="Id"/>
	<xsl:key name="Attributwert_by_AttributtypId" match="Attributwert" use="Attributtyp_Id"/>
	<xsl:key name="LCS_by_FreeTextId" match="LocalizedCharacterString" use="PT_FreeText_Id"/>
	<xsl:key name="Themeninstanz_Themeninstanz_by_Themeninstanz1" match="Themeninstanz_x005F_x_Themeninstanz" use="Themeninstanz_1"/>
	<xsl:template match="/*">
		<xsl:result-document method="xml" href="Ergebnis_XML/CIDOC_XML.xml" encoding="UTF-8" indent="yes" doctype-system="../../CIDOC_CRM_DTD/crm_entity_plhres_shorted.dtd">
			<xsl:element name="CRMset">
				<!--Wurzelelement -->
				<xsl:for-each select="key('Themeninstanz_by_ThemenauspraegungId','1')">
					<!-- nachfolgende Anweisungen für jede Themeninstanz des Themas "Münzen" durchführen -->
					<xsl:variable name="id" select="Id"/>
					<xsl:element name="E1.CRM_Entity">
						<!-- Jede Münze wird in einem E1.CRM_Entity Element beschrieben -->
						<xsl:element name="Identifier">
							<!-- Identifier Element erzeugen -->
							<xsl:value-of select="Id"/>
							<!-- Id der entsprechenden Themeninstanz als Münz ID verwenden -->
						</xsl:element>
						<xsl:element name="in_class">
							<!-- in_class Element erzeugen -->
							<xsl:value-of select="'E22.Man-Made Object'"/>
							<!-- Name der Klasse hinzufügen -->
						</xsl:element>
						<xsl:for-each select="key('Attributwert_by_AttributtypId','943')[Themeninstanz_Id=$id]">
							<!-- Auswahl der Attributwerte des Attributtyps "KurzbeschreibungMuenze" -->
							<xsl:element name="P102F.has_title">
								<!-- Element für entsprechende Eigenschaft (Property) hinzufügen -->
								<xsl:element name="Identifier">
									<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
										<!-- Freitext des Attributwertes hinzufügen -->
										<xsl:value-of select="Freitext"/>
									</xsl:for-each>
								</xsl:element>
								<xsl:element name="in_class">
									<xsl:value-of select="'E35.Title'"/>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="key('Attributwert_by_AttributtypId','419')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','902')[Themeninstanz_Id=$id]">
							<!-- Auswahl der Attributwerte der Attributtypen "Nummer Fund" und "Nummer Katalog"-->
							<xsl:element name="P48F.has_preferred_identifier">
								<xsl:element name="Identifier">
									<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
										<xsl:value-of select="Freitext"/>
									</xsl:for-each>
								</xsl:element>
								<xsl:element name="in_class">
									<xsl:value-of select="'E42.Identifier'"/>
								</xsl:element>
								<xsl:if test="Attributtyp_Id='902'">
									<!-- nachfolgendes nur für "Nummer Katalog" durchführen -->
									<xsl:element name="P71B.is_listed_in">
										<xsl:element name="Identifier">
											<xsl:value-of select="'Pergamon Fund Katalog'"/>
										</xsl:element>
										<xsl:element name="in_class">
											<xsl:value-of select="'E31.Document'"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="key('Attributwert_by_AttributtypId','942')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','941')[Themeninstanz_Id=$id]">
							<!-- Auswahl der Attributwerte der Attributtypen "Arbeitsnotiz" und "Beschreibung"-->
							<xsl:element name="P3F.has_note">
								<!-- das Element has_note weist weder das Unterelement Identifier, noch das Unterelement in_class auf, sonder das Element String -->
								<xsl:element name="String">
									<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
										<xsl:value-of select="Freitext"/>
									</xsl:for-each>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="key('Attributwert_by_AttributtypId','833')[Themeninstanz_Id=$id]">
							<xsl:element name="P45F.consists_of">
								<xsl:element name="Identifier">
									<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
										<xsl:value-of select="Freitext"/>
									</xsl:for-each>
								</xsl:element>
								<xsl:element name="in_class">
									<xsl:value-of select="'E57.Material'"/>
								</xsl:element>
								<xsl:element name="P127F.has_broader_term">
									<xsl:element name="Identifier">
										<xsl:value-of select="'Metall'"/>
									</xsl:element>
									<xsl:element name="in_class">
										<xsl:value-of select="'E55.Type'"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="key('Attributwert_by_AttributtypId','161')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','792')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','879')[Themeninstanz_Id=$id]">
							<!-- Auswahl der Attributwerte der Attributtypen "Erhaltung Gewicht", "Erhaltung Staerke" und "Erhaltung Durchmesser"-->
							<xsl:element name="P43F.has_dimension">
								<xsl:element name="Identifier"/>
								<!-- Klassen, die keine Beschreibung aufweisen erhalten eine leeres Identifier Element -->
								<xsl:element name="in_class">
									<xsl:value-of select="'E54.Dimension'"/>
								</xsl:element>
								<xsl:element name="P91F.has_unit">
									<xsl:element name="Identifier">
										<xsl:if test="Attributtyp_Id='161'">
											<xsl:value-of select="'g'"/>
										</xsl:if>
										<xsl:if test="Attributtyp_Id='792' or Attributtyp_Id='879'">
											<xsl:value-of select="'mm'"/>
										</xsl:if>
									</xsl:element>
									<xsl:element name="in_class">
										<xsl:value-of select="'E58.Measurement Unit'"/>
									</xsl:element>
								</xsl:element>
								<xsl:element name="P2F.has_type">
									<xsl:element name="Identifier">
										<xsl:if test="Attributtyp_Id='161'">
											<xsl:value-of select="'rezentes Gewicht'"/>
										</xsl:if>
										<xsl:if test="Attributtyp_Id='792'">
											<xsl:value-of select="'Stärke'"/>
										</xsl:if>
										<xsl:if test="Attributtyp_Id='879'">
											<xsl:value-of select="'Durchmesser'"/>
										</xsl:if>
									</xsl:element>
									<xsl:element name="in_class">
										<xsl:value-of select="'E55.Type'"/>
									</xsl:element>
								</xsl:element>
								<xsl:element name="P90F.has_value">
									<!-- Das Element has_value weist keine Unterelemente, sondern lediglich den Wert auf -->
									<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
										<xsl:value-of select="Freitext"/>
									</xsl:for-each>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="key('Attributwert_by_AttributtypId','880')[Themeninstanz_Id=$id]">
							<!-- Auswahl der Attributwerte des Attributtyps "Nominal" -->
							<xsl:element name="P43F.has_dimension">
								<xsl:element name="Identifier"/>
								<xsl:element name="in_class">
									<xsl:value-of select="'E54.Dimension'"/>
								</xsl:element>
								<xsl:element name="P2F.has_type">
									<xsl:element name="Identifier">
										<xsl:value-of select="'Nominal'"/>
									</xsl:element>
									<xsl:element name="in_class">
										<xsl:value-of select="'E55.Type'"/>
									</xsl:element>
								</xsl:element>
								<xsl:element name="P90F.has_value">
									<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
										<xsl:value-of select="Freitext"/>
									</xsl:for-each>
								</xsl:element>
							</xsl:element>
						</xsl:for-each>
						<xsl:if test="key('Attributwert_by_AttributtypId','883')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','884')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','956')[Themeninstanz_Id=$id]">
							<!-- Test, ob die Attributwerte der Attributtypen "Rueckseite Beistrift", "Stempelstellung" oder "Rueckseite Freitext" vorhanden sind -->
							<xsl:element name="P56F.bears_feature">
								<xsl:element name="Identifier">
									<xsl:value-of select="'Rückseite'"/>
								</xsl:element>
								<xsl:element name="in_class">
									<xsl:value-of select="'E25.Man-Made-Feature'"/>
								</xsl:element>
								<xsl:for-each select="key('Attributwert_by_AttributtypId','883')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','884')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','956')[Themeninstanz_Id=$id]">
									<!-- Auswahl der Attributwerte der Attributtypen "Rueckseite Beistrift", "Stempelstellung" und "Rueckseite Freitext" -->
									<xsl:if test="Attributtyp_Id='883'">
										<xsl:element name="P65F.shows_visual_item">
											<xsl:element name="Identifier">
												<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
													<xsl:value-of select="Freitext"/>
												</xsl:for-each>
											</xsl:element>
											<xsl:element name="in_class">
												<xsl:value-of select="'E34.Inscription'"/>
											</xsl:element>
										</xsl:element>
									</xsl:if>
									<xsl:if test="Attributtyp_Id='884'">
										<xsl:element name="P2F.has_type">
											<xsl:element name="Identifier">
												<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
													<xsl:value-of select="Freitext"/>
												</xsl:for-each>
											</xsl:element>
											<xsl:element name="in_class">
												<xsl:value-of select="'E55.Type'"/>
											</xsl:element>
										</xsl:element>
									</xsl:if>
									<xsl:if test="Attributtyp_Id='956'">
										<xsl:element name="P62F.depicts">
											<xsl:element name="Identifier"/>
											<xsl:element name="in_class">
												<xsl:value-of select="'E90.Symbolic Object'"/>
											</xsl:element>
											<xsl:element name="P3F.has_note">
												<xsl:element name="String">
													<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
														<xsl:value-of select="Freitext"/>
													</xsl:for-each>
												</xsl:element>
											</xsl:element>
										</xsl:element>
									</xsl:if>
								</xsl:for-each>
							</xsl:element>
						</xsl:if>
						<xsl:if test="key('Attributwert_by_AttributtypId','885')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','955')[Themeninstanz_Id=$id]">
							<!-- Test, ob die Attributwerte der Attributtypen "Vorderseite Beistrift" oder "Vorderseite Freitext" vorhanden sind -->
							<xsl:element name="P56F.bears_feature">
								<xsl:element name="Identifier">
									<xsl:value-of select="'Vorderseite'"/>
								</xsl:element>
								<xsl:element name="in_class">
									<xsl:value-of select="'E25.Man-Made-Feature'"/>
								</xsl:element>
								<xsl:for-each select="key('Attributwert_by_AttributtypId','885')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','955')[Themeninstanz_Id=$id]">
									<!-- Auswahl der Attributwerte der Attributtypen "Vorderseite Beistrift" und "Vorderseite Freitext" -->
									<xsl:if test="Attributtyp_Id='885'">
										<xsl:element name="P65F.shows_visual_item">
											<xsl:element name="Identifier">
												<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
													<xsl:value-of select="Freitext"/>
												</xsl:for-each>
											</xsl:element>
											<xsl:element name="in_class">
												<xsl:value-of select="'E34.Inscription'"/>
											</xsl:element>
										</xsl:element>
									</xsl:if>
									<xsl:if test="Attributtyp_Id='955'">
										<xsl:element name="P62F.depicts">
											<xsl:element name="Identifier"/>
											<xsl:element name="in_class">
												<xsl:value-of select="'E90.Symbolic Object'"/>
											</xsl:element>
											<xsl:element name="P3F.has_note">
												<xsl:element name="String">
													<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
														<xsl:value-of select="Freitext"/>
													</xsl:for-each>
												</xsl:element>
											</xsl:element>
										</xsl:element>
									</xsl:if>
								</xsl:for-each>
							</xsl:element>
						</xsl:if>
						<xsl:if test="key('Attributwert_by_AttributtypId','908')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','549')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','881')[Themeninstanz_Id=$id]">
							<!-- Test, ob die Attributwerte der Attributtypen "Muenzstaette", "Grobdatierung" oder "Praegeherr" vorhanden sind -->
							<xsl:element name="P108B.was_produced_by">
								<xsl:element name="Identifier"/>
								<xsl:element name="in_class">
									<xsl:value-of select="'E12.Production'"/>
								</xsl:element>
								<xsl:for-each select="key('Attributwert_by_AttributtypId','549')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','881')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','908')[Themeninstanz_Id=$id]">
									<!-- Auswahl der Attributwerte der Attributtypen "Grobdatierung", "Praegeherr" und "Muenzstaette" -->
									<xsl:if test="Attributtyp_Id='549'">
										<xsl:element name="P10F.falls_within">
											<xsl:element name="Identifier"/>
											<xsl:element name="in_class">
												<xsl:value-of select="'E4.Period'"/>
											</xsl:element>
											<xsl:element name="P78F.is_identified_by">
												<xsl:element name="Identifier">
													<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
														<xsl:value-of select="Freitext"/>
													</xsl:for-each>
												</xsl:element>
												<xsl:element name="in_class">
													<xsl:value-of select="'E49.Time Appellation'"/>
												</xsl:element>
											</xsl:element>
										</xsl:element>
									</xsl:if>
									<xsl:if test="Attributtyp_Id='881'">
										<xsl:element name="P17F.was_motivated_by">
											<xsl:element name="Identifier">
												<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
													<xsl:value-of select="Freitext"/>
												</xsl:for-each>
											</xsl:element>
											<xsl:element name="in_class">
												<xsl:value-of select="'E39.Actor'"/>
											</xsl:element>
										</xsl:element>
									</xsl:if>
									<xsl:if test="Attributtyp_Id='908'">
										<xsl:element name="P7F.took_place_at">
											<xsl:element name="Identifier"/>
											<xsl:element name="in_class">
												<xsl:value-of select="'E53.Place'"/>
											</xsl:element>
											<xsl:element name="P87F.is_identified_by">
												<xsl:element name="Identifier">
													<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
														<xsl:value-of select="Freitext"/>
													</xsl:for-each>
												</xsl:element>
												<xsl:element name="in_class">
													<xsl:value-of select="'E44.Place Appellation'"/>
												</xsl:element>
											</xsl:element>
										</xsl:element>
									</xsl:if>
								</xsl:for-each>
							</xsl:element>
						</xsl:if>
						<xsl:if test="key('Attributwert_by_AttributtypId','224')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','578')[Themeninstanz_Id=$id]">
							<!-- Test, ob die Attributwerte der Attributtypen "Erhaltung Prozent" oder "Erhaltung" vorhanden sind -->
							<xsl:element name="P44F.has_condition">
								<xsl:element name="Identifier"/>
								<xsl:element name="in_class">
									<xsl:value-of select="'E3.Condition State'"/>
								</xsl:element>
								<xsl:for-each select="key('Attributwert_by_AttributtypId','224')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','578')[Themeninstanz_Id=$id]">
									<!-- Auswahl der Attributwerte der Attributtypen "Erhaltung Prozent" und "Erhaltung" -->
									<xsl:if test="Attributtyp_Id='224'">
										<xsl:element name="P43F.has_dimension">
											<xsl:element name="Identifier"/>
											<xsl:element name="in_class">
												<xsl:value-of select="'E54.Dimension'"/>
											</xsl:element>
											<xsl:element name="P90F.has_value">
												<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
													<xsl:value-of select="Freitext"/>
												</xsl:for-each>
											</xsl:element>
											<xsl:element name="P91F.has_unit">
												<xsl:element name="Identifier">
													<xsl:value-of select="'%'"/>
												</xsl:element>
												<xsl:element name="in_class">
													<xsl:value-of select="'E58.Measurement Unit'"/>
												</xsl:element>
											</xsl:element>
										</xsl:element>
									</xsl:if>
									<xsl:if test="Attributtyp_Id='578'">
										<xsl:element name="P2F.has_type">
											<xsl:element name="Identifier">
												<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
													<xsl:value-of select="Freitext"/>
												</xsl:for-each>
											</xsl:element>
											<xsl:element name="in_class">
												<xsl:value-of select="'E55.Type'"/>
											</xsl:element>
										</xsl:element>
									</xsl:if>
								</xsl:for-each>
							</xsl:element>
						</xsl:if>
						<xsl:if test="key('Attributwert_by_AttributtypId','176')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','379')[Themeninstanz_Id=$id] | key('Themeninstanz_Themeninstanz_by_Themeninstanz1',$id)">
							<!-- Test, ob die Attributwerte der Attributtypen "Kampagne" oder "Funddatum", sowie zugehöriger Befund vorhanden sind -->
							<xsl:element name="P30B.custody_transferred_through">
								<xsl:element name="Identifier"/>
								<xsl:element name="in_class">
									<xsl:value-of select="'E10.Transfer of Custody'"/>
								</xsl:element>
								<xsl:element name="P2F.has_type">
									<xsl:element name="Identifier">
										<xsl:value-of select="'Fund'"/>
									</xsl:element>
									<xsl:element name="in_class">
										<xsl:value-of select="'E55.Type'"/>
									</xsl:element>
								</xsl:element>
								<xsl:if test="key('Attributwert_by_AttributtypId','176')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','379')[Themeninstanz_Id=$id]">
									<!-- Test, ob es sich um Attributwerte der Attributtypen "Kampagne" oder "Funddatum" handelt -->
									<xsl:element name="P4F.has_time-span">
										<xsl:element name="Identifier"/>
										<xsl:element name="in_class">
											<xsl:value-of select="'E52.Time-Span'"/>
										</xsl:element>
										<xsl:element name="P86F.falls_within">
											<xsl:element name="Identifier"/>
											<xsl:element name="in_class">
												<xsl:value-of select="'E52.Time-Span'"/>
											</xsl:element>
											<xsl:for-each select="key('Attributwert_by_AttributtypId','176')[Themeninstanz_Id=$id] | key('Attributwert_by_AttributtypId','379')[Themeninstanz_Id=$id]">
												<!-- Auswahl der Attributwerte der Attributtypen "Kampagne" und "Funddatum"-->
												<xsl:if test="Attributtyp_Id='176' ">
													<xsl:element name="P86F.falls_within">
														<xsl:element name="Identifier"/>
														<xsl:element name="in_class">
															<xsl:value-of select="'E52.Time-Span'"/>
														</xsl:element>
														<xsl:element name="P78F.is_identified_by">
															<xsl:element name="Identifier">
																<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
																	<xsl:value-of select="Freitext"/>
																</xsl:for-each>
															</xsl:element>
															<xsl:element name="in_class">
																<xsl:value-of select="'E50.Date'"/>
															</xsl:element>
														</xsl:element>
														<xsl:element name="P2F.has_type">
															<xsl:element name="Identifier">
																<xsl:value-of select="'Jahr'"/>
															</xsl:element>
															<xsl:element name="in_class">
																<xsl:value-of select="'E55.Type'"/>
															</xsl:element>
														</xsl:element>
													</xsl:element>
												</xsl:if>
												<xsl:if test="Attributtyp_Id='379' ">
													<xsl:element name="P2F.has_type">
														<xsl:element name="Identifier">
															<xsl:value-of select="'Datum'"/>
														</xsl:element>
														<xsl:element name="in_class">
															<xsl:value-of select="'E55.Type'"/>
														</xsl:element>
													</xsl:element>
													<xsl:element name="P78F.is_identified_by">
														<xsl:element name="Identifier">
															<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
																<xsl:value-of select="Freitext"/>
															</xsl:for-each>
														</xsl:element>
														<xsl:element name="in_class">
															<xsl:value-of select="'E50.Date'"/>
														</xsl:element>
													</xsl:element>
												</xsl:if>
											</xsl:for-each>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<xsl:if test="key('Themeninstanz_Themeninstanz_by_Themeninstanz1',$id)">
									<!-- Test, ob es sich umzugehörigen Befund handelt -->
									<xsl:element name="P7F.took_place_at">
										<xsl:element name="Identifier"/>
										<xsl:element name="in_class">
											<xsl:value-of select="'E53.Place'"/>
										</xsl:element>
										<xsl:element name="P89F.falls_within">
											<xsl:element name="Identifier"/>
											<xsl:element name="in_class">
												<xsl:value-of select="'E53.Place'"/>
											</xsl:element>
											<xsl:for-each select="key('Themeninstanz_Themeninstanz_by_Themeninstanz1',$id)">
												<!-- Auswahl der Beziehung zu Befund -->
												<xsl:for-each select="key('Themeninstanz_by_Id',Themeninstanz_2)">
													<!-- Auswahl des Befunds -->
													<xsl:variable name="id_Befund" select="Id"/>
													<xsl:element name="P53F.has_former_or_current_location">
														<xsl:element name="Identifier">
															<xsl:value-of select="Id"/>
														</xsl:element>
														<xsl:element name="in_class">
															<xsl:value-of select="'E25.Man-Made-Feature'"/>
														</xsl:element>
														<xsl:for-each select="key('Attributwert_by_AttributtypId','986')[Themeninstanz_Id=$id_Befund]">
															<!-- Auswahl des Attributwertes der Attributtypen "Nummer Befund" -->
															<xsl:element name="P48F.has_preferred_identifier">
																<xsl:element name="Identifier">
																	<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
																		<xsl:value-of select="Freitext"/>
																	</xsl:for-each>
																</xsl:element>
																<xsl:element name="in_class">
																	<xsl:value-of select="'E42.Identifier'"/>
																</xsl:element>
															</xsl:element>
														</xsl:for-each>
														<xsl:for-each select="key('Attributwert_by_AttributtypId','1017')[Themeninstanz_Id=$id_Befund]">
															<!-- Auswahl des Attributwertes der Attributtypen "KurzbeschreibungBefund" -->
															<xsl:element name="P102F.has_title">
																<xsl:element name="Identifier">
																	<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
																		<xsl:value-of select="Freitext"/>
																	</xsl:for-each>
																</xsl:element>
																<xsl:element name="in_class">
																	<xsl:value-of select="'E35.Title'"/>
																</xsl:element>
															</xsl:element>
														</xsl:for-each>
														<xsl:for-each select="key('Attributwert_by_AttributtypId','982')[Themeninstanz_Id=$id_Befund]">
															<!-- Auswahl des Attributwertes der Attributtypen "Auto Befundart" da "Befundart" nicht vergeben ist -->
															<xsl:element name="P2F.has_type">
																<xsl:element name="Identifier">
																	<xsl:for-each select="key('LCS_by_FreeTextId',Wert)[PT_Locale_Id=$locale]">
																		<xsl:value-of select="Freitext"/>
																	</xsl:for-each>
																</xsl:element>
																<xsl:element name="in_class">
																	<xsl:value-of select="'E55.Type'"/>
																</xsl:element>
																<xsl:element name="P127F.has_broader_term">
																	<xsl:element name="Identifier">
																		<xsl:value-of select="'Archaeological Feature'"/>
																	</xsl:element>
																	<xsl:element name="in_class">
																		<xsl:value-of select="'E55.Type'"/>
																	</xsl:element>
																</xsl:element>
															</xsl:element>
														</xsl:for-each>
													</xsl:element>
												</xsl:for-each>
											</xsl:for-each>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>
