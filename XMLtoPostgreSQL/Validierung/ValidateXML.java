import java.io.File;
import java.io.IOException;
import javax.xml.XMLConstants;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
 
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
 
public class ValidateXML{
 
 //erst Schema (args[0]) dann XML Datei (args[1]) angeben
public static void main(String[] args) throws IOException {
 
Source xmlFile = new StreamSource(new File(args[1]));
SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
File schemaLocation = new File(args[0]);
 
try {
 Schema schema = schemaFactory.newSchema(new StreamSource(schemaLocation));
 Validator validator = schema.newValidator();
 validator.validate(xmlFile);
 System.out.println(xmlFile.getSystemId() + " ist gueltig");
 System.exit(1);
 
} catch (SAXParseException e) {
 System.out.println(xmlFile.getSystemId() + " ist NICHT gueltig");
 System.out.println("Grund\t\t: " + e.getLocalizedMessage());
 System.out.println("Zeile \t: " + e.getLineNumber());
 System.out.println("Zeichen\t: " + e.getColumnNumber());
 System.exit(0);

 
} catch (SAXException e) {
 System.out.println(xmlFile.getSystemId() + " ist NICHT gueltig");
 System.out.println("Grund\t: " + e.getLocalizedMessage());
 System.exit(0);
 }
}
}