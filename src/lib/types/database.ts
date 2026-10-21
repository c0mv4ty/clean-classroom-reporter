// Hand-written subset of the Supabase schema (see supabase/migrations).
// Regenerate with `supabase gen types typescript` if the schema grows.

export type Rol = 'presidente' | 'admin';
export type EstadoAula = 'limpio' | 'sucio';

export type Database = {
	public: {
		Tables: {
			profiles: {
				Row: { id: string; nombre: string; rol: Rol; creado_en: string };
				Insert: { id: string; nombre: string; rol?: Rol; creado_en?: string };
				Update: { nombre?: string };
				Relationships: [];
			};
			aulas: {
				Row: {
					id: number;
					nombre: string;
					estado_actual: EstadoAula;
					actualizado_en: string | null;
				};
				Insert: {
					id?: number;
					nombre: string;
					estado_actual?: EstadoAula;
					actualizado_en?: string | null;
				};
				Update: { nombre?: string; estado_actual?: EstadoAula; actualizado_en?: string | null };
				Relationships: [];
			};
			reportes: {
				Row: {
					id: string;
					aula_id: number;
					usuario_id: string;
					estado: EstadoAula;
					nota: string | null;
					foto_path: string | null;
					creado_en: string;
				};
				Insert: {
					id?: string;
					aula_id: number;
					usuario_id?: string;
					estado: EstadoAula;
					nota?: string | null;
					foto_path?: string | null;
					creado_en?: string;
				};
				Update: never;
				Relationships: [
					{
						foreignKeyName: 'reportes_aula_id_fkey';
						columns: ['aula_id'];
						isOneToOne: false;
						referencedRelation: 'aulas';
						referencedColumns: ['id'];
					},
					{
						foreignKeyName: 'reportes_usuario_id_fkey';
						columns: ['usuario_id'];
						isOneToOne: false;
						referencedRelation: 'profiles';
						referencedColumns: ['id'];
					}
				];
			};
		};
		Views: { [_ in never]: never };
		Functions: {
			is_admin: { Args: Record<string, never>; Returns: boolean };
			// Admin-only (checked inside the function): previous report of the same aula.
			admin_reportes_previos: {
				Args: { p_ids: string[] };
				Returns: {
					reporte_id: string;
					anterior_id: string;
					anterior_usuario_id: string;
					anterior_nombre: string;
					anterior_estado: EstadoAula;
					anterior_creado_en: string;
				}[];
			};
			// Admin-only: users whose report was the last one before a sucio report.
			admin_resumen_reporte_previo: {
				Args: { p_aula_id?: number };
				Returns: {
					anterior_usuario_id: string;
					anterior_nombre: string;
					veces: number;
					ultima_vez: string;
				}[];
			};
		};
		Enums: { rol_usuario: Rol; estado_aula: EstadoAula };
		CompositeTypes: { [_ in never]: never };
	};
};

export type Aula = Database['public']['Tables']['aulas']['Row'];
export type Reporte = Database['public']['Tables']['reportes']['Row'];
export type Profile = Database['public']['Tables']['profiles']['Row'];
